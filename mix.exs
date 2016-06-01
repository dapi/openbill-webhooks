defmodule OpenbillWebhooks.Mixfile do
  use Mix.Project

  def project do
    [app: :openbill_webhooks,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:httpotion, :boltun, :logger],
      mod: {OpenbillWebhooks, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:exrm, "~> 1.0"},
      {:boltun, git: "https://github.com/cultureamp/boltun"},
      {:httpotion, "~> 2.2.0"},
      {:logger_file_backend, git: "https://github.com/onkel-dirtus/logger_file_backend"}
   ]
  end
end
