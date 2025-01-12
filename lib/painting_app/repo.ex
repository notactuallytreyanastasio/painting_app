defmodule PaintingApp.Repo do
  use Ecto.Repo,
    otp_app: :painting_app,
    adapter: Ecto.Adapters.Postgres
end
