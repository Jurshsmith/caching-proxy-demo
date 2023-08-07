defmodule CachingProxyDemo.Marvel.Page do
  @moduledoc """
  A typical page in Marvel
  """

  @default_limit 20

  @type t() :: %__MODULE__{
          page: non_neg_integer(),
          limit: non_neg_integer(),
          offset: non_neg_integer()
        }

  @fields [:page, :limit, :offset]

  @enforce_keys @fields
  defstruct @fields

  def as_query_params(nil), do: []

  def as_query_params(%__MODULE__{} = page) do
    [limit: page.limit, offset: page.offset]
  end

  @spec from_json(map()) :: t() | nil
  def from_json(json) when json == %{}, do: nil

  def from_json(json) when is_map(json) do
    limit = Map.get(json, "limit", "#{@default_limit}") |> String.to_integer()
    offset = Map.fetch!(json, "offset") |> String.to_integer()

    current(limit, offset)
  end

  def current(limit, offset) do
    %__MODULE__{
      page: page(limit, offset),
      limit: limit,
      offset: offset
    }
  end

  def next(limit, offset, total) do
    %__MODULE__{
      page: page(limit, offset),
      limit: limit,
      offset: min(total, offset + limit)
    }
  end

  def previous(limit, offset) do
    %__MODULE__{
      page: page(limit, offset),
      limit: limit,
      offset: max(0, offset - limit)
    }
  end

  defp page(limit, offset) do
    ceil((offset + limit) / limit)
  end
end
