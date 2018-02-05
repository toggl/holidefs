defmodule Holidefs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Holidefs.Store, nil}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Holidefs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
