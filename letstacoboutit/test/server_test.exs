defmodule ServerTest do
  use ExUnit.Case, async: true

  setup do
    Server.start_link(:test)
    :ok
  end

  test "Create a New Review for a truck" do
    assert :ok == Server.add_truck_review(:test, "Off the Grid Services, LLC", 8.5, "Anton Ego")
  end

  test "Create a New Review for a truck that doesnt exist" do
    assert :ok == Server.add_truck_review(:test, "Imaginary Cart", 8.5, "Anton Ego")
  end

  test "Create multiple reviews for a truck" do
    assert :ok == Server.add_truck_review(:test, "Off the Grid Services, LLC", 8.5, "Anton Ego")
    assert :ok == Server.add_truck_review(:test, "Off the Grid Services, LLC", 9.5, "Guy Fieri")
  end

  test "Get reviews for a truck" do
    Server.add_truck_review(:test, "Brazuca Grill", 8.5, "Anton Ego")
    Server.add_truck_review(:test, "Brazuca Grill", 9.9, "Guy Fieri")

    assert {:ok,
            %TacoTruck{
              name: "Brazuca Grill",
              reviews: [
                %Review{user: "Guy Fieri", rating: 9.9},
                %Review{user: "Anton Ego", rating: 8.5}
              ]
            }} == Server.get_truck_reviews(:test, "Brazuca Grill")
  end

  test "Get reviews for a truck with an anonymous review" do
    Server.add_truck_review(:test, "Curry Up Now", 9.9)

    assert {:ok,
            %TacoTruck{name: "Curry Up Now", reviews: [%Review{user: "Anonymous", rating: 9.9}]}} ==
             Server.get_truck_reviews(:test, "Curry Up Now")
  end

  test "Get reviews for a truck with no reviews" do
    assert {:ok, %TacoTruck{name: "Natan's Catering", reviews: []}} ==
             Server.get_truck_reviews(:test, "Natan's Catering")
  end

  test "Get reviews for a truck that doesnt exists" do
    assert {:error, :truck_not_found} == Server.get_truck_reviews(:test, "Imaginary Cart")
  end

  test "Get average rating for a truck" do
    Server.add_truck_review(:test, "Faith Sandwich", 8.5, "Anton Ego")
    Server.add_truck_review(:test, "Faith Sandwich", 4.0, "Guy Fieri")
    assert {:ok, 6.25} == Server.get_truck_average_rating(:test, "Faith Sandwich")
  end

  test "Get average rating for a truck with no reviews" do
    assert {:ok, 0} == Server.get_truck_average_rating(:test, "Natan's Catering")
  end

  test "Get average rating for a truck that doesnt exist" do
    assert {:error, :truck_not_found} == Server.get_truck_average_rating(:test, "Imaginary Truck")
  end
end
