defmodule CachingProxyDemo.MarvelTest do
  use CachingProxyDemo.DataCase, async: true

  import Mox

  alias CachingProxyDemo.Marvel
  alias CachingProxyDemo.Marvel.{Cache, Page, PaginatedData, Character, HTTPClientMock}

  alias CachingProxyDemo.HTTPRequests.HTTPRequest

  alias CachingProxyDemo.CacheMock

  alias CachingProxyDemo.Repo

  setup :verify_on_exit!

  describe "fetch_characters" do
    test "makes GET request to characters endpoint" do
      expect(HTTPClientMock, :get, fn endpoint_url, _query_params ->
        assert endpoint_url == "/v1/public/characters"

        {:ok, %{status: 200, body: fetch_characters_response()}}
      end)

      Marvel.fetch_characters(nil)
    end

    test "makes request with empty query params with nil Page" do
      page = nil

      expect(HTTPClientMock, :get, fn _endpoint_url, query_params ->
        assert query_params == []

        {:ok, %{status: 200, body: fetch_characters_response()}}
      end)

      Marvel.fetch_characters(page)
    end

    test "makes request with query params for a given Page" do
      page = build(:marvel_page)

      expect(HTTPClientMock, :get, fn _endpoint_url, query_params ->
        assert query_params == Page.as_query_params(page)

        {:ok, %{status: 200, body: fetch_characters_response()}}
      end)

      Marvel.fetch_characters(page)
    end

    test "deserializes paginated characters when characters are successfully returned" do
      expect(HTTPClientMock, :get, fn _endpoint_url, _query_params ->
        {:ok, %{status: 200, body: fetch_characters_response()}}
      end)

      assert {:ok, %PaginatedData{data: [%Character{}]}} = Marvel.fetch_characters()
    end

    test "simply returns error when request fails" do
      expect(HTTPClientMock, :get, fn _endpoint_url, _query_params ->
        {:error, :some_error}
      end)

      assert {:error, :some_error} = Marvel.fetch_characters()
    end

    test "records HTTPRequest when request is successful" do
      assert Repo.all(HTTPRequest) == []

      expect(HTTPClientMock, :get, fn _endpoint_url, _query_params ->
        {:ok, %{status: 200, body: fetch_characters_response()}}
      end)

      assert {:ok, _result} = Marvel.fetch_characters()

      assert [
               %HTTPRequest{
                 method: :get,
                 url: "/v1/public/characters",
                 status: :successful,
                 inserted_at: %DateTime{}
               }
             ] = Repo.all(HTTPRequest)
    end

    test "doesn't record HTTPRequest when request fails" do
      assert Repo.all(HTTPRequest) == []

      expect(HTTPClientMock, :get, fn _endpoint_url, _query_params ->
        {:error, :some_error}
      end)

      assert {:error, _error} = Marvel.fetch_characters()

      assert Repo.all(HTTPRequest) == []
    end
  end

  describe "fetch_characters_with_caching" do
    test "caches returned characters for nil Page" do
      expected_name = Cache.name()
      expected_key = Cache.key("/v1/public/characters", [nil])

      response = fetch_characters_response()
      expected_value = {:ok, Marvel.paginated_characters_from_json(response)}

      expect(HTTPClientMock, :get, fn _endpoint_url, _query_params ->
        {:ok, %{status: 200, body: response}}
      end)

      expect(CacheMock, :get, fn ^expected_name, ^expected_key -> nil end)

      expect(CacheMock, :set, fn ^expected_name, ^expected_key, ^expected_value ->
        :ok
      end)

      assert Marvel.fetch_characters_with_caching() == expected_value
    end

    test "returns cache if page has previously been requested" do
      expected_name = Cache.name()
      expected_key = Cache.key("/v1/public/characters", [nil])

      response = fetch_characters_response()
      cached_value = {:ok, Marvel.paginated_characters_from_json(response)}

      expect(CacheMock, :get, fn ^expected_name, ^expected_key -> cached_value end)

      assert Marvel.fetch_characters_with_caching() == cached_value
    end

    test "doesn't set cache again if cached value was returned" do
      cached_value = {:ok, Marvel.paginated_characters_from_json(fetch_characters_response())}

      expect(CacheMock, :get, fn _expected_name, _expected_key -> cached_value end)

      expect(CacheMock, :set, 0, fn _name, _key, _value -> :ok end)

      assert Marvel.fetch_characters_with_caching() == cached_value
    end

    test "doesn't make an HTTP request if cached value was returned " do
      response = fetch_characters_response()
      cached_value = {:ok, Marvel.paginated_characters_from_json(response)}

      expect(CacheMock, :get, fn _expected_name, _expected_key -> cached_value end)

      expect(HTTPClientMock, :get, 0, fn _endpoint_url, _query_params ->
        {:ok, %{status: 200, body: response}}
      end)

      assert Marvel.fetch_characters_with_caching() == cached_value
    end

    test "doesn't cache when request fails" do
      expect(HTTPClientMock, :get, fn _endpoint_url, _query_params ->
        {:error, :some_error}
      end)

      expect(CacheMock, :get, fn _name, _key -> nil end)
      expect(CacheMock, :set, 0, fn _name, _key, _value -> :ok end)

      assert {:error, :some_error} == Marvel.fetch_characters_with_caching()
    end
  end

  def fetch_characters_response do
    %{
      "data" => %{
        "results" => [
          %{
            "id" => Enum.random(0..1_200),
            "modified" => "2017-08-21T14:47:52-0400",
            "name" => "Sample Character Name",
            "description" => "Sample description",
            "resourceURI" => "http://gateway.marvel.com/v1/public/characters/1009378",
            "thumbnail" => %{
              "extension" => "jpg",
              "path" => "http://i.annihil.us/u/prod/marvel/i/mg/d/00/5390e41260345"
            }
          }
        ],
        "count" => Enum.random(1..100),
        "total" => Enum.random(1..400),
        "limit" => Enum.random(1..20),
        "offset" => Enum.random(1..400)
      }
    }
  end
end
