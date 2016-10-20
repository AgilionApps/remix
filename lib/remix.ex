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

    def start_link do
      Process.send_after(__MODULE__, :poll_and_reload, 10000)
      GenServer.start_link(__MODULE__, %{}, name: Remix.Worker)
    end

    def handle_info(:poll_and_reload, state) do
      paths = Application.get_all_env(:remix)[:paths]

      new_state = Map.new paths, fn (path) ->
        current_mtime = get_current_mtime path
        last_mtime = case Map.fetch(state, path) do
          {:ok, val} -> val
          :error -> nil
        end
        handle_path path, current_mtime, last_mtime
      end

      Process.send_after(__MODULE__, :poll_and_reload, 1000)
      {:noreply, new_state}
    end

    def handle_path(path, current_mtime, current_mtime), do: {path, current_mtime}
    def handle_path(path, current_mtime, _) do
      comp_elixir = fn -> Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"]) end
      comp_escript = fn -> Mix.Tasks.Escript.Build.run([]) end

      case Application.get_all_env(:remix)[:silent] do
        true ->
          ExUnit.CaptureIO.capture_io(comp_elixir)
          if Application.get_all_env(:remix)[:escript] == true do
            ExUnit.CaptureIO.capture_io(comp_escript)
          end

        _ ->
          comp_elixir.()
          if Application.get_all_env(:remix)[:escript] == true do
            comp_escript.()
          end
      end
      {path, current_mtime}
    end

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
      get_current_mtime tail, [mtime | mtimes], cwd
    end
  end
end
