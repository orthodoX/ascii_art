defmodule AsciiArt.Drawings do
  @moduledoc """
  The Drawings context.
  """
  import Ecto.Query, warn: false

  alias AsciiArt.Drawings.{Canvas, Rectangle}
  alias AsciiArt.Repo

  @doc """
  Returns the list of canvases.

  ## Examples

      iex> list_canvases()
      [%Canvas{}, ...]

  """
  def list_canvases, do: Repo.all(Canvas)

  @doc """
  Gets a single canvas.

  Raises `Ecto.NoResultsError` if the Canvas does not exist.

  ## Examples

      iex> get_canvas!(123)
      %Canvas{}

      iex> get_canvas!(456)
      ** (Ecto.NoResultsError)

  """
  def get_canvas!(id), do: Repo.get!(Canvas, id)

  @doc """
  Creates a canvas.

  ## Examples

      iex> create_canvas(%{field: value})
      {:ok, %Canvas{}}

      iex> create_canvas(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_canvas(attrs \\ %{}) do
    %Canvas{}
    |> Canvas.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a canvas.

  ## Examples

      iex> update_canvas(canvas, %{field: new_value})
      {:ok, %Canvas{}}

      iex> update_canvas(canvas, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_canvas(%Canvas{} = canvas, attrs) do
    canvas
    |> Canvas.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a canvas.

  ## Examples

      iex> delete_canvas(canvas)
      {:ok, %Canvas{}}

      iex> delete_canvas(canvas)
      {:error, %Ecto.Changeset{}}

  """
  def delete_canvas(%Canvas{} = canvas), do: Repo.delete(canvas)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking canvas changes.

  ## Examples

      iex> change_canvas(canvas)
      %Ecto.Changeset{data: %Canvas{}}

  """
  def change_canvas(%Canvas{} = canvas, attrs \\ %{}), do: Canvas.changeset(canvas, attrs)

  @doc """
    Draws a canvas string with drawings based on passed structs.

  ## Examples

      iex> draw_canvas([%Rectangle{}, ...])
      "xxxx oooo ..."

  """
  def draw_canvas(rectangles, flood_params \\ %{}) do
    generate_canvas(rectangles, flood_params) |> Enum.join("\n")
  end

  defp generate_canvas(rectangles, flood_params) when flood_params == %{} do
    generate_drawings(rectangles)
    |> Enum.scan(&merge_drawings(&1, &2))
    |> List.last()
  end

  defp generate_drawings(rectangles), do: rectangles |> Enum.map(&add_drawing/1)

  defp add_drawing(rectangle) do
    for row <- 0..Rectangle.end_row(rectangle), into: [], do: add_rows(row, rectangle)
  end

  defp add_rows(row, rectangle) do
    if row < Rectangle.start_row(rectangle), do: [], else: add_columns(row, rectangle)
  end

  defp add_columns(row, rectangle) do
    start_row = Rectangle.start_row(rectangle)
    end_row = Rectangle.end_row(rectangle)
    start_column = Rectangle.start_column(rectangle)
    end_column = Rectangle.end_column(rectangle)
    outline = Rectangle.outline_char(rectangle)
    fill = Rectangle.fill_char(rectangle)

    for column <- 0..end_column, into: [] do
      cond do
        column < start_column -> " "
        row == start_row or row == end_row -> outline
        column == start_column or column == end_column -> outline
        column > start_column and column < end_column -> fill
      end
    end
  end

  defp merge_drawings(rect1, rect2) do
    total_rows = ([Enum.count(rect1), Enum.count(rect2)] |> Enum.max()) - 1

    total_cols =
      [
        rect1 |> Enum.max_by(&Enum.count/1) |> Enum.count(),
        rect2 |> Enum.max_by(&Enum.count/1) |> Enum.count()
      ]
      |> Enum.max()

    for row <- 0..total_rows, into: [] do
      rect1_row = rect1 |> Enum.at(row)
      rect2_row = rect2 |> Enum.at(row)

      cond do
        is_nil(rect1_row) ->
          rect2_row

        is_nil(rect2_row) ->
          rect1_row

        Enum.empty?(rect1_row) or Enum.empty?(rect2_row) ->
          merge_empty_row(rect1_row, rect2_row)

        true ->
          merge_rows(rect1_row, rect2_row, total_cols)
      end
    end
  end

  defp merge_empty_row(row1, row2) do
    cond do
      Enum.empty?(row1) and Enum.empty?(row2) -> []
      Enum.empty?(row1) -> row2
      true -> row1
    end
  end

  defp merge_rows(rect1_row, rect2_row, total_cols) do
    for column <- 0..total_cols, into: [] do
      rect1_col = rect1_row |> Enum.at(column)
      rect2_col = rect2_row |> Enum.at(column)

      cond do
        is_nil(rect1_col) and is_nil(rect2_col) -> ""
        is_nil(rect1_col) -> rect2_col
        is_nil(rect2_col) -> rect1_col
        true -> merge_columns(rect1_col, rect2_col)
      end
    end
  end

  defp merge_columns(col1, col2) when col1 == " ", do: col2
  defp merge_columns(col1, _col2), do: col1
end
