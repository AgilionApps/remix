defmodule Remix do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Remix.Worker, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Remix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmodule Worker do
    use GenServer

    defmodule State, do: defstruct last_mtime: nil

    def start_link do
      Process.send_after(__MODULE__, :poll_and_reload, 10000)
      GenServer.start_link(__MODULE__, %State{}, name: Remix.Worker)
    end

    def handle_info(:poll_and_reload, state) do
      current_mtime = get_current_mtime

      if state.last_mtime != current_mtime do
        state = %State{last_mtime: current_mtime}
        comp_elixir = fn -> Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"]) end
        comp_escript = fn -> Mix.Tasks.Escript.Build.run([]) end

        case Mix.Project.get.remix[:silent] do
          true ->
            ExUnit.CaptureIO.capture_io(comp_elixir)
            if Mix.Project.get.remix[:escript] == true do
              ExUnit.CaptureIO.capture_io(comp_escript)
            end

          _ ->
            comp_elixir.()
            if Mix.Project.get.remix[:escript] == true do
              comp_escript.()
            end
        end
      end

      Process.send_after(__MODULE__, :poll_and_reload, 1000)
      {:noreply, state}
    end

    defp compile_stuffs do
      case Mix.Project.get.remix[:escript] do
        true -> Mix.Tasks.Escript.Build.run([])
        _ -> nil
      end
      Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
    end


    def get_current_mtime, do: get_current_mtime("lib")

    def get_current_mtime(dir) do
      case File.ls(dir) do
        {:ok, files} -> get_current_mtime(files, [], dir)
        _            -> nil
      end
    end

    def get_current_mtime([], mtimes, _cwd) do
      mtimes
      |> Enum.sort
      |> Enum.reverse
      |> List.first
    end

    def get_current_mtime([h | tail], mtimes, cwd) do
      mtime = case File.dir?("#{cwd}/#{h}") do
        true  -> get_current_mtime("#{cwd}/#{h}")
        false -> File.stat!("#{cwd}/#{h}").mtime
      end
      get_current_mtime(tail, [mtime | mtimes], cwd)
    end
  end
end
