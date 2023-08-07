defmodule CachingProxyDemo.Marvel.PaginatedData do
  @moduledoc """
  Pagination structure Marvel APIs returning a list of items
  """

  alias CachingProxyDemo.Marvel.Page

  @type t(data_type) :: %__MODULE__{
          total: non_neg_integer(),
          total_pages: non_neg_integer(),
          count: non_neg_integer(),
          data: list(data_type),
          current_page: Page.t(),
          next_page: Page.t(),
          previous_page: Page.t()
        }

  @fields [:total, :total_pages, :count, :data, :current_page, :previous_page, :next_page]

  @enforce_keys @fields
  defstruct @fields

  @spec from_json!(map()) :: t(struct())
  def from_json!(json) when is_map(json) do
    total = Map.fetch!(json, "total")
    limit = Map.fetch!(json, "limit")
    offset = Map.fetch!(json, "offset")

    total_pages = ceil(total / limit)

    %__MODULE__{
      total: total,
      total_pages: total_pages,
      count: Map.fetch!(json, "count"),
      data: Map.fetch!(json, "results"),
      current_page: Page.current(limit, offset),
      next_page: Page.next(limit, offset, total),
      previous_page: Page.previous(limit, offset)
    }
  end
end
