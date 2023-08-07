defmodule CachingProxyDemo.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: CachingProxyDemo.Repo

  alias CachingProxyDemo.Marvel.Character, as: MarvelCharacter
  alias CachingProxyDemo.Marvel.Image, as: MarvelImage
  alias CachingProxyDemo.Marvel.Page, as: MarvelPage
  alias CachingProxyDemo.Marvel.PaginatedData

  def marvel_paginated_data_factory do
    %PaginatedData{
      total: Enum.random(1..20),
      total_pages: Enum.random(1..20),
      count: Enum.random(1..20),
      data: [],
      current_page: build(:marvel_page),
      next_page: build(:marvel_page),
      previous_page: build(:marvel_page)
    }
  end

  def marvel_page_factory do
    %MarvelPage{
      page: Enum.random(1..20),
      limit: Enum.random(1..20),
      offset: Enum.random(1..20)
    }
  end

  def marvel_character_factory do
    %MarvelCharacter{
      id: Enum.random(1..1_000),
      name: sequence(:character_name, &"Character #{&1}"),
      description: sequence(:character_description, &"Description #{&1}"),
      modified: DateTime.utc_now(),
      resource_uri: sequence(:character_resource_uri, &"https:://resource.com/#{&1}"),
      thumbnail: build(:marvel_image)
    }
  end

  def marvel_image_factory do
    %MarvelImage{
      path: "https://some-image",
      extension: ".png",
      image_url: "https://some-image.png"
    }
  end
end
