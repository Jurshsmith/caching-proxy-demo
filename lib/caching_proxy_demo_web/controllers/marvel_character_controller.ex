defmodule CachingProxyDemoWeb.MarvelCharacterController do
  use CachingProxyDemoWeb, :controller

  alias CachingProxyDemo.Marvel

  def index(conn, params) do
    {:ok, characters} =
      params
      |> Map.take(~w(limit offset))
      |> Marvel.Page.from_json()
      |> marvel_module().fetch_characters_with_caching()

    render(conn, :index, layout: false, characters: characters)
  end

  defp marvel_module do
    Application.get_env(:caching_proxy_demo, :marvel_module, Marvel)
  end
end
