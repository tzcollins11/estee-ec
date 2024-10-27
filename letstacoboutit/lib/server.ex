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
    # Would never do this in actual production code, I would probably use like a seed file
    # but for ease of use for team when they checkout and start up the app its a nice to have
    return_pid_tuple = GenServer.start_link(__MODULE__, load_trucks(), name: __MODULE__)
    preseed_user_reviews()
    return_pid_tuple
  end

  @spec get_truck_reviews(pid() | module(), String.t()) ::
          {:error, :truck_not_found} | {:ok, any()}
  @doc """
  Retrieve any truck reviews for a given truck name

  Returns {ok, truck} or {:error, :truck_not found}.

  ## Examples

  iex> Server.get_truck_reviews(Server, "Quan Catering")
  {:ok,
  %TacoTruck{
   name: "Quan Catering",
   reviews: [
     %Review{user: "Gordon Ramsey", rating: 10.0},
     %Review{user: "Anthony Bourdain", rating: 10.0},
     %Review{user: "Guy Fieri", rating: 4.0},
     %Review{user: "Anton Ego", rating: 9.0}
   ]
  }}

  iex(2)> Server.get_truck_reviews(Server, "Tonys Catering")
  {:error, :truck_not_found}

  """
  def get_truck_reviews(pid, truck) do
    GenServer.call(pid, {:get_truck_reviews, truck})
  end

  @spec get_truck_average_rating(pid() | module(), String.t()) ::
          {:error, :truck_not_found} | {:ok, float()}
  @doc """
  Retrieve the average truck rating for a given truck name

  Returns {ok, float()} or {:error, :truck_not found}.

  ## Examples

  iex> Server.get_truck_average_rating(Server, "Quan Catering")
  {:ok, 8.25}

  iex > Server.get_truck_average_rating(Server, "Tonys Catering")
  {:error, :truck_not_found}
  """
  def get_truck_average_rating(pid, truck) do
    GenServer.call(pid, {:get_truck_average_rating, truck})
  end

  @spec add_truck_review(pid() | module(), String.t(), float(), String.t()) :: :ok
  @doc """
  Add a review for a given truck name, always return :ok regardless if the truck exists or not

  Returns :ok

  ## Examples

  iex> Server.add_truck_review(Server, "Quan Catering", 8.5)
  :ok
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
    # Imported Nimble to handle parsing the CSV. Pulling the name from Enum.at(1) is a bit ugly but for now
    # we are only going to support one truck at a global level rather than treat each truck as its own entity
    # Docs can be found at https://hexdocs.pm/nimble_csv/NimbleCSV.html

    "Mobile_Food_Facility_Permit.csv"
    |> File.stream!(read_ahead: 100_000)
    |> TruckParser.parse_stream()
    |> Stream.map(fn truck_line -> %TacoTruck{name: Enum.at(truck_line, 1)} end)
    |> Enum.to_list()
    |> build_truckset(%{})
  end

  # Tail Recursion to build out K/V map where Key is the name and V is the truck itself
  defp build_truckset([], acc), do: acc

  defp build_truckset([h | t], acc) do
    build_truckset(t, Map.put(acc, h.name, h))
  end

  # A bit hacky but calling this in server start function and iterate through and generate some reviews
  defp preseed_user_reviews do
    users = ["Anton Ego", "Guy Fieri", "Anthony Bourdain", "Gordon Ramsey"]
    trucks = ["Quan Catering", "Brazuca Grill", "Treats by the Bay LLC"]

    Enum.each(users, fn user ->
      Enum.each(trucks, fn truck ->
        add_truck_review(Server, truck, Enum.random(1..10) / 1, user)
      end)
    end)
  end
end
