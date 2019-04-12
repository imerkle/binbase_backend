defmodule BinbaseBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :binbase_backend,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BinbaseBackend.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      
      {:phoenix_token_plug, "~> 0.2"},
      {:con_cache, "~> 0.13"},
      {:ex_machina, "~> 2.2", only: :test},

      #passwords & ids
      {:comeonin, "~> 4.1"},
      {:argon2_elixir, "~> 1.3"},
      {:hashids, "~> 2.0"},

      #crypto funcs
      {:omni, git: "https://github.com/imerkle/omni.git"},

      #rabbitmq
      {:amqp, "~> 1.1.1"},
      {:ranch, "~> 1.6.2", override: true},

      #email
      {:bamboo, "~> 1.2"},
      {:bamboo_smtp, "~> 1.6.0"},      

    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.reset --quiet", "test"]
    ]
  end
end
