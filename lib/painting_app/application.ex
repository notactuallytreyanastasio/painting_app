defmodule PaintingApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PaintingAppWeb.Telemetry,
      PaintingApp.Repo,
      {DNSCluster, query: Application.get_env(:painting_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PaintingApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PaintingApp.Finch},
      {PaintingApp.PaintingStore, []},
      # Start a worker by calling: PaintingApp.Worker.start_link(arg)
      # {PaintingApp.Worker, arg},
      # Start to serve requests, typically the last entry
      PaintingAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaintingApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PaintingAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
