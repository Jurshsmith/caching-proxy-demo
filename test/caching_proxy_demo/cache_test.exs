defmodule CachingProxyDemo.CacheTest do
  use CachingProxyDemo.DataCase, async: true

  alias CachingProxyDemo.Cache

  @cache_name TestCache

  describe "get/2" do
    setup do
      start_supervised!({Cache, name: @cache_name})

      :ok
    end

    test "returns nil if cache doesn't exist" do
      refute Cache.get(@cache_name, :non_existent_key)
    end

    test "returns cached value if cache does exist" do
      key = key()
      value = value()

      Cache.set(@cache_name, key, value)

      assert Cache.get(@cache_name, key) == value
    end

    test "returns latest cache value every single time" do
      key = key()
      [stale_value, latest_value] = [value(), {value()}]

      Cache.set(@cache_name, key, stale_value)
      Cache.set(@cache_name, key, latest_value)

      assert Cache.get(@cache_name, key) == latest_value
    end

    defp key, do: Enum.random([:some_key, ["key"], 1_200, "some-key", {:some, :key}])
    defp value, do: Enum.random([:some_value, ["some_value"], 1_000_000, {:some, :value}])
  end
end
