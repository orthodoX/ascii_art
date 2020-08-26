defmodule AsciiArtWeb.ChangesetView do
  use AsciiArtWeb, :view

  def render("error.json", _) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{
      error: "
      make sure rectangles have valid coordinates, width, height and either outline or fill character
      " |> String.trim()
    }
  end
end
