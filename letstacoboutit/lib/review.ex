defmodule Review do
  @moduledoc """
  A review and if user is not supplied, we use Anonymous
  """
  defstruct [:user, :rating]

  def new(rating, user \\ "Anonymous") do
    %__MODULE__{user: user, rating: rating}
  end
end
