defmodule CachingProxyDemo.Marvel.Cache do
  @moduledoc """
  Caches responses for Marvel API requests
  """
  alias CachingProxyDemo.Cache

  @cache_name __MODULE__

  def name, do: @cache_name

  @spec key(String.t(), list()) :: Cache.key()
  def key(endpoint_url, params) when is_binary(endpoint_url) and is_list(params) do
    {endpoint_url, params}
  end

  @spec resolve_with_caching(Cache.key(), source :: (() -> any())) :: Cache.value()
  def resolve_with_caching(key, source) when is_function(source) do
    case get(key) do
      nil -> set(key, source.())
      value -> value
    end
  end

  @spec set(Cache.key(), Cache.value()) :: Cache.value()
  def set(_key, {:error, error}), do: {:error, error}

  def set(key, value) do
    :ok = cache().set(@cache_name, key, value)

    value
  end

  @spec get(Cache.key()) :: Cache.value() | nil
  def get(key) do
    cache().get(@cache_name, key)
  end

  defp cache do
    Application.get_env(:caching_proxy_demo, :cache, Cache)
  end
end
