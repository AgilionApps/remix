defmodule Remix.Mixfile do
  use Mix.Project

  def project do
    [
      app: :remix,
      version: "0.0.4",
      elixir: "~> 1.6.1",
      package: package(),
      description: description(),
      deps: deps()
   ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Remix, []}
    ]
  end

  defp deps, do: []

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Alan Peabody", "Mike Westbom", "Jordan Morano", "Brendan Fey", "Alik Send"],
      links: %{
        "GitHub" => "https://github.com/aliksend/remix"
      }
    ]
  end

  defp description do
    """
    Recompiles mix projects on any change to the lib directory.
    """
  end
end
