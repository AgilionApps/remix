defmodule Remix.Worker do
  use GenServer

  def start_link do
    Process.send_after(__MODULE__, :poll_and_reload, 5000)
    GenServer.start_link(__MODULE__, %{}, name: Remix.Worker)
  end

  ## callbacks

  def init(args) do
    { :ok, args }
  end

  def handle_info(:poll_and_reload, state) do
    paths = Application.get_env(:remix, :projects_paths, default_paths()) ++ Application.get_env(:remix, :additional_paths, [])

    new_state = Map.new paths, fn (path) ->
      current_mtime = get_current_mtime path
      last_mtime = case Map.fetch(state, path) do
        {:ok, val} -> val
        :error -> nil
      end
      handle_path path, current_mtime, last_mtime
    end

    poll_and_reload_interval = Application.get_env(:remix, :poll_and_reload_interval, 3000)
    Process.send_after(__MODULE__, :poll_and_reload, poll_and_reload_interval)
    {:noreply, new_state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ## private

  defp handle_path(path, current_mtime, current_mtime), do: {path, current_mtime}
  defp handle_path(path, current_mtime, _) do
    silence_wrapper fn ->
      umbrella_wrapper fn ->
        Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
        if Application.get_env(:remix, :escript, false) do
          Mix.Tasks.Escript.Build.run([])
        end
      end
    end

    {path, current_mtime}
  end

  defp silence_wrapper(func) do
    if Application.get_env(:remix, :silent, false) do
      ExUnit.CaptureIO.capture_io(func)
    else
      func.()
    end
  end

  defp umbrella_wrapper(func) do
    if Mix.Project.umbrella? do
      Mix.Project.apps_paths
      |> Enum.each(fn { app, path } when is_atom(app) and is_binary(path) ->
        Mix.Project.in_project(app, path, fn _module_name ->
          if Mix.Project.config()[:remix] do
            func.()
          end
        end)
      end)
    else
      func.()
    end
  end

  defp default_paths do
    if Mix.Project.umbrella? do
      Mix.Project.apps_paths()
      |> Map.values()
      |> Enum.map(fn s -> "#{s}/lib" end)
    else
      ["lib"]
    end
  end

  defp get_current_mtime(dir) do
    case File.ls(dir) do
      {:ok, files} -> get_current_mtime(files, [], dir)
      _            -> nil
    end
  end

  defp get_current_mtime([], mtimes, _cwd) do
    mtimes
      |> Enum.sort
      |> Enum.reverse
      |> List.first
  end

  defp get_current_mtime([h | tail], mtimes, cwd) do
    mtime = case File.dir?("#{cwd}/#{h}") do
      true  -> get_current_mtime("#{cwd}/#{h}")
      false -> File.stat!("#{cwd}/#{h}").mtime
    end
    get_current_mtime tail, [mtime | mtimes], cwd
  end
end
