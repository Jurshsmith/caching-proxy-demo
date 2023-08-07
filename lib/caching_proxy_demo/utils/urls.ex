defmodule CachingProxyDemo.Utils.Urls do
  @moduledoc """
  Provides augmenting functions to build and transform
  url strings
  """

  @doc """
     ## Appends query parameters to url.

      iex> append_query_params("https://marvel.com", %{limit: 2})
      "https://marvel.com?limit=2"

      iex> append_query_params("https://marvel.com", [limit: 2])
      "https://marvel.com?limit=2"
  """
  @spec append_query_params(String.t() | URI.t(), map() | keyword()) :: String.t()
  def append_query_params(url, params) do
    url
    |> URI.new!()
    |> URI.append_query(URI.encode_query(params))
    |> URI.to_string()
  end
end
