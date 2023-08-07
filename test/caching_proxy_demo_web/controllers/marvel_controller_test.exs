defmodule CachingProxyDemoWeb.MarvelCharacterControllerTest do
  use CachingProxyDemoWeb.ConnCase, async: true

  import Mox

  alias CachingProxyDemo.Utils.Urls
  alias CachingProxyDemo.Marvel.Page, as: MarvelPage
  alias CachingProxyDemo.MarvelMock

  setup :verify_on_exit!

  describe "index" do
    test "renders the names of Marvel characters", %{conn: conn} do
      characters = build_list(2, :marvel_character)
      paginated_characters = build(:marvel_paginated_data, data: characters)

      expect(MarvelMock, :fetch_characters_with_caching, fn nil ->
        {:ok, paginated_characters}
      end)

      conn = get(conn, ~p"/")

      html_response = html_response(conn, 200)

      for character <- characters do
        assert html_response =~ character.name
      end
    end

    test "renders the current page number for all pages", %{conn: conn} do
      current_page = build(:marvel_page, page: 2)
      paginated_characters = build(:marvel_paginated_data, current_page: current_page)

      expect(MarvelMock, :fetch_characters_with_caching, fn page ->
        assert page.limit == current_page.limit
        assert page.offset == current_page.offset

        {:ok, paginated_characters}
      end)

      route = Urls.append_query_params(~p"/", MarvelPage.as_query_params(current_page))
      conn = get(conn, route)

      assert html_response(conn, 200) =~ "Page #{current_page.page}"
    end

    test "renders the total pages", %{conn: conn} do
      paginated_characters = build(:marvel_paginated_data)

      expect(MarvelMock, :fetch_characters_with_caching, fn nil ->
        {:ok, paginated_characters}
      end)

      conn = get(conn, ~p"/")

      assert html_response(conn, 200) =~ "of #{paginated_characters.total_pages}"
    end

    test "renders next page button", %{conn: conn} do
      paginated_characters = build(:marvel_paginated_data)

      expect(MarvelMock, :fetch_characters_with_caching, fn nil ->
        {:ok, paginated_characters}
      end)

      conn = get(conn, ~p"/")

      expected_next_page_url =
        "href=\"/?limit=#{paginated_characters.next_page.limit}&amp;offset=#{paginated_characters.next_page.offset}\""

      assert html_response(conn, 200) =~ expected_next_page_url
    end

    test "renders previous page button", %{conn: conn} do
      paginated_characters = build(:marvel_paginated_data)

      expect(MarvelMock, :fetch_characters_with_caching, fn nil ->
        {:ok, paginated_characters}
      end)

      conn = get(conn, ~p"/")

      expected_previous_page_url =
        "href=\"/?limit=#{paginated_characters.previous_page.limit}&amp;offset=#{paginated_characters.previous_page.offset}\""

      assert html_response(conn, 200) =~ expected_previous_page_url
    end
  end
end
