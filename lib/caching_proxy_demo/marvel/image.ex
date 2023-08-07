defmodule CachingProxyDemo.Marvel.Image do
  @moduledoc """
  A Marvel Image
  """

  @type t :: %__MODULE__{
          path: String.t(),
          extension: String.t(),
          image_url: String.t()
        }

  @fields [:path, :extension, :image_url]

  @enforce_keys @fields
  defstruct @fields

  @spec from_json!(map()) :: t()
  def from_json!(json) when is_map(json) do
    path = Map.fetch!(json, "path")
    extension = Map.fetch!(json, "extension")

    %__MODULE__{
      path: path,
      extension: extension,
      image_url: Enum.join([path, extension], ".")
    }
  end
end
