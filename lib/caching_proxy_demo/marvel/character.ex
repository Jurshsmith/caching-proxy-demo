defmodule CachingProxyDemo.Marvel.Character do
  @moduledoc """
  A Marvel character
  """

  alias CachingProxyDemo.Marvel.Image

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          description: String.t(),
          modified: DateTime.t(),
          resource_uri: String.t(),
          thumbnail: Image.t()
        }

  # TODO: Update with missing fields: urls, comics, stories, events, series
  @fields [:id, :name, :description, :modified, :resource_uri, :thumbnail]

  @enforce_keys @fields
  defstruct @fields

  @spec from_json_list!([map()]) :: list(t())
  def from_json_list!(json_list) when is_list(json_list) do
    Enum.map(json_list, &from_json!/1)
  end

  @spec from_json!(map()) :: t()
  def from_json!(json) when is_map(json) do
    {:ok, modified, _offset} = json |> Map.fetch!("modified") |> DateTime.from_iso8601()

    %__MODULE__{
      id: Map.fetch!(json, "id"),
      name: Map.fetch!(json, "name"),
      description: Map.fetch!(json, "description"),
      modified: modified,
      resource_uri: Map.fetch!(json, "resourceURI"),
      thumbnail: json |> Map.fetch!("thumbnail") |> Image.from_json!()
    }
  end
end
