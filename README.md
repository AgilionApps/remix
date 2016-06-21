# Remix

Recompiles mix project on any file change/addition (defaults to only watching `lib`).

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

## Config
  * `dirs` (default `"lib"`): A list of directories to search, or binary of a single directory
  * `escript` (default `false`): includes escript compilation
  * `silent` (default `false`): suppress output to iex when compiling

Watches all files in project, with escript compilation and silent mode:
```elixir
config :remix,
  dirs: "./",
  escript: true,
  silent: true
```

Watches the `lib` and `foo` directories
```elixir
config :remix,
  dirs: ["lib", "foo"]
```

## Usage

Save or create a new file in the lib (or other specified) directory. Thats it!

## About

Co-authored by the Agilion team during a Brown Bag Beers learning session as an exploration into Elixir, OTP, and recursion.

## License

Remix source code is released under the Apache 2 License. Check LICENSE file for more information.
