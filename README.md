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

## Usage

Save or create a new file in the lib directory. Thats it!

## License

Remix source code is released under the Apache 2 License. Check LICENSE file for more information.
