defmodule ModelTest.Repo do
  use Ecto.Repo,
    otp_app: :model_test,
    adapter: Ecto.Adapters.SQLite3
end
