defmodule CachingProxyDemo.Marvel.Errors do
  @moduledoc """
  Houses all possible errors in Marvel context
  """

  defmodule RateLimitedError do
    @fields [:message]

    @type t :: %__MODULE__{}

    @enforce_keys @fields
    defstruct @fields
  end

  defmodule InternalServerError do
    @fields [:message]

    @type t :: %__MODULE__{}

    @enforce_keys @fields
    defstruct @fields
  end

  @type t() :: RateLimitedError.t() | InternalServerError.t()
end
