defmodule Nested.Mixfile do
  use Mix.Project

  def project do
    [ app: :nested,
      version: "0.1.5",
      elixir: ">= 0.13.0 and <= 0.14.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    []
  end
end
