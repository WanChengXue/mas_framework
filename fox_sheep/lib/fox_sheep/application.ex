defmodule FoxSheep.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoxSheepWeb.Telemetry,
      FoxSheep.Repo,
      {DNSCluster, query: Application.get_env(:fox_sheep, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FoxSheep.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FoxSheep.Finch},
      # Start a worker by calling: FoxSheep.Worker.start_link(arg)
      # {FoxSheep.Worker, arg},
      # Start to serve requests, typically the last entry
      FoxSheepWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FoxSheep.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoxSheepWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
