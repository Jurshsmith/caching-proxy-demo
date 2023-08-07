defmodule CachingProxyDemo.HTTPRequests do
  @moduledoc """
  Reponsible for reading and recording HTTPRequests
  """
  alias CachingProxyDemo.Repo

  import Ecto.Query, only: [where: 2]

  defmodule HTTPRequest do
    @moduledoc """
    An HTTP Request
    """
    use Ecto.Schema

    import Ecto.Changeset

    @type method :: atom()
    @type url :: String.t()

    @methods ~w(get post patch delete)a
    @statuses ~w(successful failed)a

    @type t() :: %__MODULE__{}

    @primary_key {:id, :binary_id, autogenerate: true}
    schema "http_requests" do
      field :url, :string
      field :method, Ecto.Enum, values: @methods
      field :status, Ecto.Enum, values: @statuses

      timestamps(type: :utc_datetime, updated_at: false)
    end

    @spec successful_changeset(method(), url()) :: Ecto.Changeset.t()
    def successful_changeset(method, url) do
      %__MODULE__{}
      |> change(url: url, method: method)
      |> put_change(:status, :successful)
    end
  end

  @spec record_successful_http_request(HTTPRequest.method(), HTTPRequest.url()) ::
          {:ok, HTTPRequest.t()} | {:error, Ecto.Changeset.t()}
  def record_successful_http_request(method, url) do
    HTTPRequest.successful_changeset(method, url)
    |> Repo.insert()
  end

  @spec get_successful_http_requests(HTTPRequest.method(), HTTPRequest.url()) :: [HTTPRequest.t()]
  def get_successful_http_requests(method, url) do
    HTTPRequest
    |> where(method: ^method)
    |> where(url: ^url)
    |> where(status: :successful)
    |> Repo.all()
  end
end
