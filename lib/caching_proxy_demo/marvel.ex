defmodule CachingProxyDemo.Marvel do
  @moduledoc """
  Context for Marvel (https://www.marvel.com/)
  """

  alias CachingProxyDemo.HTTPRequests
  alias CachingProxyDemo.Marvel.{Character, Cache, HTTPClient, Page, PaginatedData}

  require Logger

  @fetch_characters_endpoint_url "/v1/public/characters"
  @spec fetch_characters(Page.t() | nil) ::
          {:ok, PaginatedData.t(Character.t())} | HTTPClient.error()
  def fetch_characters(page \\ nil) do
    Logger.info("[Marvel] Fetching Characters...")

    case http_client().get(@fetch_characters_endpoint_url, Page.as_query_params(page)) do
      {:ok, %{status: 200, body: json_response}} ->
        _ignore =
          HTTPRequests.record_successful_http_request(:get, @fetch_characters_endpoint_url)

        {:ok, paginated_characters_from_json(json_response)}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec fetch_characters_with_caching(Page.t() | nil) ::
          {:ok, PaginatedData.t(Character.t())} | HTTPClient.error()
  def fetch_characters_with_caching(page \\ nil) do
    key = Cache.key(@fetch_characters_endpoint_url, [page])

    Cache.resolve_with_caching(key, fn -> fetch_characters(page) end)
  end

  def paginated_characters_from_json(json_response) do
    json_response
    |> Map.fetch!("data")
    |> Map.update!("results", &Character.from_json_list!/1)
    |> PaginatedData.from_json!()
  end

  defp http_client do
    Application.get_env(:caching_proxy_demo, :marvel_http_client, HTTPClient)
  end

  @callback fetch_characters(Page.t() | nil) ::
              {:ok, PaginatedData.t(Character.t())} | HTTPClient.error()

  @callback fetch_characters_with_caching(Page.t() | nil) ::
              {:ok, PaginatedData.t(Character.t())} | HTTPClient.error()
end
