defmodule AppsignalElli.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_elli,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp elixirc_paths(env) do
    case env do
      :test -> ["lib", "test/support"]
      _ -> ["lib"]
    end
  end

  defp deps do
    [
      # Elli web server
      {:elli, "~> 2.0"},
      # Appsignal monitoring
      {:appsignal, "~> 1.5"},
      # Automatic test runner
      {:mix_test_watch, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
