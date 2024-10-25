defmodule Server do
  @moduledoc """
  Main application to be able to leave reviews and fetch reviews on trucks
  """

  use GenServer
  NimbleCSV.define(TruckParser, separator: ",")

  @spec start_link(any()) :: {:ok, pid()}
  def start_link(:test) do
    GenServer.start_link(__MODULE__, load_trucks(), name: :test)
  end

  @spec start_link(any()) :: {:ok, pid()}
  def start_link(_opts) do
    return_pid_tuple = GenServer.start_link(__MODULE__, load_trucks(), name: __MODULE__)
    preseed_user_reviews()
    return_pid_tuple
  end

  @spec get_truck_reviews(pid() | module(), String.t()) :: {:error, :truck_not_found} | {:ok, any()}
  @doc """
  Retrieve any truck reviews for a given truck name
  """
  def get_truck_reviews(pid, truck) do
    GenServer.call(pid, {:get_truck_reviews, truck})
  end

  @spec get_truck_average_rating(pid() | module(), String.t()) ::
          {:error, :truck_not_found} | {:ok, float()}
  @doc """
  Retrieve the average truck rating for a given truck name
  """
  def get_truck_average_rating(pid, truck) do
    GenServer.call(pid, {:get_truck_average_rating, truck})
  end

  @spec add_truck_review(pid() | module(), String.t(), float(), String.t()) :: :ok
  @doc """
  Add a review for a given truck name, always return :ok regardless if the truck exists or not
  """
  def add_truck_review(pid, truck, rating, user \\ "Anonymous") do
    review = Review.new(rating, user)
    GenServer.cast(pid, {:add_review, truck, review})
  end

  # GenServer Callbacks
  def handle_cast({:add_review, truck, review}, state) do
    case Map.get(state, truck) do
      nil ->
        {:noreply, state}

      %TacoTruck{name: name, reviews: prev_reviews} ->
        updated_truck = %TacoTruck{name: name, reviews: [review | prev_reviews]}
        {:noreply, Map.put(state, name, updated_truck)}
    end
  end

  def handle_call({:get_truck_reviews, truck}, _from, state) do
    case Map.get(state, truck) do
      nil -> {:reply, {:error, :truck_not_found}, state}
      truck -> {:reply, {:ok, truck}, state}
    end
  end

  def handle_call({:get_truck_average_rating, truck}, _from, state) do
    case Map.get(state, truck) do
      nil -> {:reply, {:error, :truck_not_found}, state}
      truck -> {:reply, {:ok, TacoTruck.avg_rating(truck)}, state}
    end
  end

  def init(state), do: {:ok, state}

  # Private function to Load in the trucks from the CSV
  defp load_trucks do
    # Imported Nimble to handle parsing the CSV. Pattern match ignoring all the other fields is a bit ugly but
    # for now we are only going to support one truck at a global level rather than treat each truck as its own entity
    # Docs can be found at https://hexdocs.pm/nimble_csv/NimbleCSV.html

    "Mobile_Food_Facility_Permit.csv"
    |> File.stream!(read_ahead: 100_000)
    |> TruckParser.parse_stream()
    |> Stream.map(fn [
                       _,
                       name,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _,
                       _
                     ] ->
      %TacoTruck{name: name}
    end)
    |> Enum.to_list()
    |> build_truckset(%{})
  end

  # Tail Recursion to build out K/V map where Key is the name and V is the truck itself
  defp build_truckset([], acc), do: acc

  defp build_truckset([h | t], acc) do
    build_truckset(t, Map.put(acc, h.name, h))
  end

  # A bit hacky but call this in  a tap function and iterate through and generate some reviews
  defp preseed_user_reviews do
    users = ["Anton Ego", "Guy Fieri", "Anthony Bourdain", "Gordon Ramsey"]
    trucks = ["Quan Catering", "Brazuca Grill", "Treats by the Bay LLC"]

    Enum.each(users, fn user ->
      Enum.each(trucks, fn truck ->
        add_truck_review(Server, truck, (Enum.random(1..10) / 1), user)
      end)
    end)
  end
end
