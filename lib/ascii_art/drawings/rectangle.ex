defmodule AsciiArt.Drawings.Rectangle do
  @moduledoc """
  A rectangle mapping module. Provides struct, and helper functions.
  """
  defstruct coordinates: [], width: nil, height: nil, outline: "none", fill: "none"

  @doc """
  Builds a rectangle struct from the string map.

  ## Examples

      iex> build_from attrs(%{"coordinates" => [1, 7], ...})
      %Rectangle{}

  """
  def build_from_attrs(attrs) do
    attrs =
      Map.new(attrs, fn {key, value} ->
        {String.to_atom(key), value}
      end)

    struct(__MODULE__, attrs)
  end

  @doc """
  Returns a start row passed in the coordinates.

  ## Examples

      iex> start_row(%Rectangle{})
      3

  """
  def start_row(rectangle), do: start_coords(rectangle).row

  @doc """
  Returns an end row of the rectangle based on start row and height.

  ## Examples

      iex> end_row(%Rectangle{})
      7

  """
  def end_row(rectangle), do: start_row(rectangle) + rectangle.height - 1

  @doc """
  Returns a start column passed in the coordinates.

  ## Examples

      iex> start_column(%Rectangle{})
      4

  """
  def start_column(rectangle), do: start_coords(rectangle).column

  @doc """
  Returns an end column of the rectangle based on start column and width.

  ## Examples

      iex> end_column(%Rectangle{})
      12

  """
  def end_column(rectangle), do: start_coords(rectangle).column + rectangle.width - 1

  @doc """
  Returns the outline char for the rectangle passed in the struct.
  In case "none" is passed, it will fallback to the fill characted instead.

  ## Examples

      iex> outline_char(%Rectangle{})
      "X"

  """
  def outline_char(rectangle) do
    if rectangle.outline == "none", do: rectangle.fill, else: rectangle.outline
  end

  @doc """
  Returns the fill char for the rectangle passed in the struct.
  In case "none" is passed, it will fallback to the whitespace characted instead.

  ## Examples

      iex> inline_char(%Rectangle{})
      "."

  """
  def fill_char(rectangle) do
    if rectangle.fill == "none", do: " ", else: rectangle.fill
  end

  @doc """
  Returns true or false boolean if the rectangle is valid.

  ## Examples

      iex> valid?(%Rectangle{})
      true

  """
  def valid?(rectangle) do
    cond do
      Enum.empty?(rectangle.coordinates) -> false
      is_nil(rectangle.width) or is_nil(rectangle.height) -> false
      rectangle.fill == "none" and rectangle.outline == "none" -> false
      true -> true
    end
  end

  defp start_coords(%{coordinates: [column, row]}), do: %{column: column, row: row}
end
