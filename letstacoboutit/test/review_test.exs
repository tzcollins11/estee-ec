defmodule ReviewTest do
  use ExUnit.Case

  test "Create a New Review" do
    assert %Review{user: "Guy Fieri", rating: 8.0} ==
             Review.new(8.0, "Guy Fieri")
  end

  test "Create a New Review for an anon user" do
    assert %Review{user: "Anonymous", rating: 5.0} == Review.new(5.0)
  end
end
