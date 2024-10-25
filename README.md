# estee-ec
Engineering Challenge For Estee about food trucks

Goal of project is to create a yelp style application where users can store food reviews for store locations. The Stores will be seeded from the CSV provided.

The App is "Lets Taco Bout It" a taco review application where the user can review their favorite food truck with their name or if they want to stay hidden, anonymously. 

# How to start

mix deps.get
iex -S mix

# How To Function
Our App Supervisor has started the GenServer link and Registered it to the pid "Server"

iex> Server.get_truck_reviews(Server, "Curry Up Now")
{:ok, %TacoTruck{name: "Curry Up Now", reviews: []}}

iex> Server.add_truck_review(Server, "Curry Up Now", 9.3, "Anton Ego")
:ok

iex> Server.add_truck_review(Server, "Curry Up Now", 8.2, "Guy Fieri")
:ok

iex> Server.get_truck_reviews(Server, "Curry Up Now")
{:ok,
 %TacoTruck{
   name: "Curry Up Now",
   reviews: [
     %Review{user: "Guy Fieri", rating: 8.2},
     %Review{user: "Anton Ego", rating: 9.3}
   ]
 }}

iex> Server.get_truck_average_rating(Server, "Curry Up Now")
{:ok, 8.75}

For ease of use, whens starting the application server I have preseeded the application with reviews from some users with random scores on the following resteraunts.

Quan Catering
Brazuca Grill
Treats by the Bay LLC

For Example
iex> Server.get_truck_reviews(Server, "Brazuca Grill")
{:ok,
 %TacoTruck{
   name: "Brazuca Grill",
   reviews: [
     %Review{user: "Gordon Ramsey", rating: 2.0},
     %Review{user: "Anthony Bourdain", rating: 3.0},
     %Review{user: "Guy Fieri", rating: 7.0},
     %Review{user: "Anton Ego", rating: 3.0}
   ]
 }}

# Fault Tolerance
While we hope that our server never crashes we have introduced a supervisor layer to ensure to manage our applications starting and stopping and restarting the child (Server) after a potential crash

# Dependencies
{:nimble_csv, "~> 1.1"} -> CSV Parsing
{:dialyxir, "~> 1.3", only: [:dev], runtime: false}, -> Code analysis, type checking
{:credo, "~> 1.7", only: [:dev, :test], runtime: false} -> Code analysis, duplication

# Features to add if I had more time
Currently we only support adding ratings from verified users and anon users. However we could introduce some better filtering (Using something like Enum.filter) to retrieve only verified user reviews. We could also implement a get all that is Sorted by highest average rating or get all from a certain reviewer

# Areas of improvement
Full transparancy I am fairly new to Gen Server/ Supervision implementations as they were previously handled by a platform team at my most recent company. Having a supervisor that starts the GenServer, and then opening a new Supervisor process when running Mix Test and registering the pid to :test I am not sure is the best solution. I would need to look a bit further into best practices around testing these supervised services. 
