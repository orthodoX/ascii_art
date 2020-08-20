defmodule AsciiArt.Repo.Migrations.CreateCanvases do
  use Ecto.Migration

  def change do
    create table(:canvases) do
      add :drawing, :text

      timestamps()
    end
  end
end
