defmodule Remix do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Remix.Worker,
        start: { Remix.Worker, :start_link, [] }
      },
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Remix.Supervisor)
  end
end
