defmodule ExParse.Mixfile do
  use Mix.Project

  def project do
    [ app: :exparse,
      version: "0.0.1",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      test_coverage: [tool: ExCoveralls],
      prefered_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
      ],
      dialyzer: [
        plt_file: "deps/plt_#{System.version}_#{:erlang.system_info(:otp_release)}.plt"
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
    [{:earmark,  "~> 1.0",   only: :dev},
     {:ex_doc,   "~> 0.14",  only: :dev},
     {:dialyxir, "~> 0.3",   only: :dev},

     # {:excheck,  "~> 0.3",   only: :test},
     # {:triq, github: "krestenkrab/triq", only: :test},

     {:inch_ex,  "~> 0.5", only: :dev},
     {:credo,    "~> 0.4", only: :dev},

     {:excoveralls, "~> 0.5", only: :test}]
  end
end
