defmodule FoxSheep.Repo do
  use Ecto.Repo,
    otp_app: :fox_sheep,
    adapter: Ecto.Adapters.SQLite3
end
