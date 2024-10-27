defmodule TacoTruck do
  @moduledoc """
  A Taco truck has a name and list of ratings associated with that truck

  ##Example
     %TacoTruck{name: "Tacos", Reviews: [%Review{}]}
  """
  defstruct [:name, reviews: []]

  @spec avg_rating(any()) :: float()
  @doc """
  Get average rating, if there are no ratings yet, return 0. Always round down to 2 decimals.

  Returns floating number
  """
  def avg_rating(%{reviews: []}), do: 0

  def avg_rating(%{reviews: reviews}) do
    total_rating = Enum.reduce(reviews, 0, fn review, acc -> review.rating + acc end)

    (total_rating / length(reviews))
    |> Float.floor(2)
  end
end
