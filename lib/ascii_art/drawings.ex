defmodule AsciiArt.Drawings do
  @moduledoc """
  The Drawings context.
  """
  import Ecto.Query, warn: false

  alias AsciiArt.Drawings.{Canvas, Rectangle}
  alias AsciiArt.{Matrix, Repo}

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
    %Canvas{drawing: from_attrs(attrs)}
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
    |> Canvas.changeset(%{drawing: from_attrs(attrs)})
    |> Repo.update()
  end

  defp from_attrs(%{"rectangles" => attrs, "flood_fill" => flood_attrs}) do
    from_attrs(attrs, flood_attrs)
  end

  defp from_attrs(%{"rectangles" => attrs}), do: from_attrs(attrs, %{})

  defp from_attrs(_), do: nil

  defp from_attrs(rectangles_attrs, flood_attrs) do
    rectangles = rectangles_attrs |> Enum.map(&Rectangle.build_from_attrs/1)

    if Enum.find(rectangles, fn rect -> !Rectangle.valid?(rect) end) do
      nil
    else
      draw_canvas(rectangles, flood_attrs)
    end
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
  def draw_canvas(rectangles, flood_attrs \\ %{}) do
    generate_canvas(rectangles, flood_attrs) |> Enum.join("\n")
  end

  defp generate_canvas(rectangles, flood_attrs) when flood_attrs == %{} do
    generate_drawings(rectangles) |> Enum.reduce(&merge_drawings(&1, &2))
  end

  defp generate_canvas(rectangles, flood_attrs) do
    generate_canvas(rectangles, %{}) |> flood_fill(flood_attrs)
  end

  defp flood_fill(canvas, flood_attrs) do
    canvas
    |> equalize_rows()
    |> Matrix.from_list()
    |> fill_matrix(flood_attrs)
    |> Matrix.to_list()
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
    {total_rows, total_cols} = find_max_sizes(rect1, rect2)

    for row <- 0..total_rows, into: [] do
      rect1_row = rect1 |> Enum.at(row)
      rect2_row = rect2 |> Enum.at(row)

      cond do
        is_nil(rect1_row) -> rect2_row
        is_nil(rect2_row) -> rect1_row
        Enum.any?([rect1_row, rect2_row], &Enum.empty?/1) -> merge_empty_row(rect1_row, rect2_row)
        true -> merge_rows(rect1_row, rect2_row, total_cols)
      end
    end
  end

  defp find_max_sizes(list1, list2) do
    total_rows = ([Enum.count(list1), Enum.count(list2)] |> Enum.max()) - 1

    total_cols =
      ([
         list1 |> Enum.max_by(&Enum.count/1) |> Enum.count(),
         list2 |> Enum.max_by(&Enum.count/1) |> Enum.count()
       ]
       |> Enum.max()) - 1

    {total_rows, total_cols}
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

  defp fill_matrix(matrix, %{"coordinates" => [start_column, start_row], "fill" => fill}) do
    matrix |> fill_fields(start_row, start_column, fill)
  end

  defp fill_fields(matrix, neighbours, _) when neighbours == [], do: matrix

  defp fill_fields(neighbours, matrix, fill) when is_list(neighbours) and is_map(matrix) do
    neighbours
    |> Enum.reduce(matrix, fn [row, col], acc -> acc |> put_in([row, col], fill) end)
    |> fill_fields(neighbours, fill)
  end

  defp fill_fields(matrix, neighbours, fill) do
    for [row, col] <- neighbours do
      find_neighbours(matrix, row, col)
    end
    |> Enum.concat()
    |> fill_fields(matrix, fill)
  end

  defp fill_fields(matrix, row, col, fill) do
    find_neighbours(matrix, row, col) |> fill_fields(matrix, fill)
  end

  defp find_neighbours(matrix, row, col) do
    potential_neighbours = [[row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]]
    {height, width} = Canvas.size()

    for [r, c] <- potential_neighbours, into: [] do
      if r <= height and c <= width and Enum.member?([" ", ""], matrix[r][c]), do: [r, c]
    end
    |> Enum.reject(&is_nil/1)
  end

  defp equalize_rows(list) do
    total_rows = Enum.count(list) - 1
    max_cols = list |> Enum.max_by(&Enum.count/1) |> Enum.count()

    Enum.reduce(0..total_rows, list, fn index, list ->
      row = list |> Enum.at(index)
      cols = row |> Enum.count()
      missing_cols = max_cols - cols
      fillers = for _n when missing_cols > 0 <- 0..missing_cols, into: [], do: ""

      list |> List.replace_at(index, row ++ fillers)
    end)
  end
end
