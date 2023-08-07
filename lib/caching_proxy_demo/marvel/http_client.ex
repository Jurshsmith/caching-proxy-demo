defmodule CachingProxyDemo.Marvel.HTTPClient do
  @moduledoc """
   Houses Marvel HTTP API functions for https://developer.marvel.com/docs
  """

  alias CachingProxyDemo.Marvel.Errors.{RateLimitedError, InternalServerError}
  alias CachingProxyDemo.Utils.Urls

  require Logger

  @timeout_opts [pool_timeout: 15_000, receive_timeout: 15_000]

  @type error :: {:error, Errors.t()}
  @type http_response :: %{status: pos_integer(), body: map() | String.t()}

  @spec get(String.t(), query_params :: keyword() | map()) ::
          {:ok, http_response()} | error
  def get(endpoint_url, query_params) do
    [base_url(), endpoint_url]
    |> Enum.join()
    |> Urls.append_query_params(api_credentials())
    |> Urls.append_query_params(query_params)
    |> then(&Finch.build(:get, &1))
    |> Finch.request(CachingProxyDemo.Finch, @timeout_opts)
    |> process_http_response()
  end

  def api_credentials do
    current_timestamp = current_timestamp()

    %{
      "apikey" => public_key(),
      "ts" => current_timestamp,
      "hash" => md5_hash("#{current_timestamp}#{private_key()}#{public_key()}")
    }
  end

  defp public_key do
    Application.fetch_env!(:caching_proxy_demo, :marvel_public_key)
  end

  defp private_key do
    Application.fetch_env!(:caching_proxy_demo, :marvel_private_key)
  end

  defp current_timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp md5_hash(data) do
    :crypto.hash(:md5, data) |> Base.encode16(case: :lower)
  end

  defp base_url do
    Application.get_env(:caching_proxy_demo, :marvel_api_url, "https://gateway.marvel.com:443")
  end

  defp process_http_response({:error, error}), do: {:error, error}

  defp process_http_response({:ok, %{status: 429, body: body}}) do
    Logger.warn("[MarvelHTTPClient] Rate limited error: #{inspect(body)}")

    {:error, %RateLimitedError{message: body}}
  end

  defp process_http_response({:ok, %{status: 500, body: body}}) do
    Logger.warn("[MarvelHTTPClient] Internal server error: #{inspect(body)}")

    {:error, %InternalServerError{message: body}}
  end

  defp process_http_response({:ok, %{status: status, body: body}}) do
    {:ok, %{status: status, body: maybe_decode_json(body)}}
  end

  defp maybe_decode_json(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        decoded

      {:error, _jason_error} ->
        body
    end
  end

  @callback get(String.t(), query_params :: keyword() | map()) ::
              {:ok, http_response()} | error
end
