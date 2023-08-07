defmodule CachingProxyDemo.Cache do
  @moduledoc """
  A KV store that helps cache arbitrary data
  """

  use GenServer

  @type key :: any()
  @type value :: any()
  @type table_name :: atom()

  defmodule Config do
    @fields [:table_name]

    @type t :: %__MODULE__{}

    @enforce_keys @fields
    defstruct @fields
  end

  defmodule NotFoundError do
    @type t :: %__MODULE__{}

    defstruct []
  end

  @spec set(table_name(), key(), value()) :: :ok
  def set(table_name, key, value) do
    GenServer.call(table_name, {:set, key, value})
  end

  @spec fetch(table_name(), key()) :: {:ok, value()} | {:error, Error.t()}
  def fetch(table_name, key) do
    case :ets.lookup(table_name, key) do
      [{_key, value}] -> {:ok, value}
      [] -> {:error, %NotFoundError{}}
    end
  end

  @spec get(table_name(), key()) :: value() | nil
  def get(table_name, key) do
    case fetch(table_name, key) do
      {:ok, value} -> value
      {:error, %NotFoundError{}} -> nil
    end
  end

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    cache_config = %Config{table_name: name}

    GenServer.start_link(__MODULE__, cache_config, name: name)
  end

  @impl GenServer
  def init(cache_config) do
    setup(cache_config)

    {:ok, cache_config}
  end

  @impl GenServer
  def handle_call({:set, key, value}, _from, %Config{table_name: table_name} = state) do
    :ets.insert(table_name, {key, value})

    {:reply, :ok, state}
  end

  defp setup(%Config{table_name: table_name}) do
    :ets.new(table_name, [:named_table, :set, :protected, read_concurrency: true])

    :ok
  end

  @callback get(table_name(), key()) :: value() | nil
  @callback set(table_name(), key(), value()) :: :ok
end
