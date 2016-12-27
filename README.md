# Remix

Recompiles mix project on any lib file change/addition.

Intended for development use only.

## Installation

Add remix to deps:

```elixir
defp deps do
  [{:remix, "~> 0.0.1", only: :dev}]
end
```

Add add `:remix` as a development only OTP app.

```elixir

def application do
  [applications: applications(Mix.env)]
end

defp applications(:dev), do: applications(:all) ++ [:remix]
defp applications(_all), do: [:logger]

```

with escript compilation (in config.exs) and
silent mode (won't output to iex each time it compiles):
```elixir
config :remix,
  escript: true,
  silent: true,
  paths: ["lib"]
```
If these vars are not set, it will default to verbose (silent: false) and no escript compilation (escript: false).

## Usage

Save or create a new file in the lib directory. Thats it!

## About

Co-authored by the Agilion team during a Brown Bag Beers learning session as an exploration into Elixir, OTP, and recursion.

## License

Remix source code is released under the Apache 2 License. Check LICENSE file for more information.
