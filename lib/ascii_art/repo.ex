defmodule AsciiArt.Repo do
  use Ecto.Repo,
    otp_app: :ascii_art,
    adapter: Ecto.Adapters.Postgres
end
