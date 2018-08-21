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

Available configuration options with default values:
```elixir
config :remix,
  poll_and_reload_interval: 3000 # files watching interval
  escript: false,                # escript compilation
  silent: false,                 # silent mode (won't output to iex each time it compiles)
  projects_paths: ["lib"]        # paths to watch (for classic project; you can read about umbrella projects in corresponding section)
  additional_paths: []           # additional paths to watch (useful for umbrella projects)
```

## Difference for umbrella projects

Default `projects_paths` for umbrella projects will contains `lib` directories of all your projects.

For umbrella projects you must add `remix:true` to project config of apps where you want to use remix:
```elixir
use Mix.Project

def project do
  [
    # ...
    remix: Mix.env == :dev
  ]
end
```

Also because dependencies specified in umbrella's `mix.exs` isn't started with your applications,
it is recommended to create `my_remix` app in your apps directory and add `:remix` to dependencies there.
You don't need any  configuration or code in this app, it is needed only to start `:remix` for your umbrella project.
For now it is only solution, but I created [question on forum](https://elixirforum.com/t/mix-umbrella-apps-not-started/13359).

## Usage

Save or create a new file in the lib directory. Thats it!

## About

Co-authored by the Agilion team during a Brown Bag Beers learning session as an exploration into Elixir, OTP, and recursion.

### Changes in fork

- Added support for umbrella applications.
- Fixed warnings and tested on elixir 1.6.4

## License

Remix source code is released under the Apache 2 License. Check LICENSE file for more information.
