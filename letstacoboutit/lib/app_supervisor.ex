defmodule AppSupervisor do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Server, []}
    ]

    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end
end
