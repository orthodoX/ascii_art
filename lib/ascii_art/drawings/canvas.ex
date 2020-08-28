defmodule AsciiArt.Drawings.Canvas do
  use Ecto.Schema

  import Ecto.Changeset

  @size {20, 20}

  schema "canvases" do
    field :drawing, :string

    timestamps()
  end

  @doc false
  def size, do: @size

  @doc false
  def changeset(canvas, attrs) do
    canvas
    |> cast(attrs, [:drawing])
    |> validate_required([:drawing])
  end
end
