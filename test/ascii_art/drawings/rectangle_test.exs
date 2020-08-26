defmodule AsciiArt.Drawings.RectangleTest do
  use AsciiArt.DataCase

  alias AsciiArt.Drawings.Rectangle

  describe "rectangle helper functions" do
    def rectangle_fixture(outline \\ nil, fill \\ nil) do
      %Rectangle{
        coordinates: [14, 0],
        width: 7,
        height: 6,
        outline: outline || "X",
        fill: fill || "O"
      }
    end

    test "build_from_attrs/1 returns a rectangle struct" do
      attrs = %{
        "coordinates" => [14, 0],
        "fill" => "O",
        "height" => 6,
        "outline" => "X",
        "width" => 7
      }

      assert Rectangle.build_from_attrs(attrs) == rectangle_fixture()
    end

    test "start_row/1 returns start row" do
      rectangle = rectangle_fixture()

      assert Rectangle.start_row(rectangle) == 0
    end

    test "end_row/1 returns end row" do
      rectangle = rectangle_fixture()

      assert Rectangle.end_row(rectangle) == 5
    end

    test "start_column/1 returns start column" do
      rectangle = rectangle_fixture()

      assert Rectangle.start_column(rectangle) == 14
    end

    test "end_column/1 returns end row" do
      rectangle = rectangle_fixture()

      assert Rectangle.end_column(rectangle) == 20
    end

    test "outline_char/1 returns outline char if passed" do
      rectangle = rectangle_fixture("@")

      assert Rectangle.outline_char(rectangle) == "@"
    end

    test "outline_char/1 fallbaks to fill char if outline char not passed" do
      rectangle = rectangle_fixture("none")

      assert Rectangle.outline_char(rectangle) == "O"
    end

    test "fill_char/1 returns fill char if passed" do
      rectangle = rectangle_fixture("@", ".")

      assert Rectangle.fill_char(rectangle) == "."
    end

    test "fill_char/1 fallbaks to whitespace char if fill char not passed" do
      rectangle = rectangle_fixture("@", "none")

      assert Rectangle.fill_char(rectangle) == " "
    end

    test "valid?/1 returns true only if rectangle has valid attrs" do
      rectangle = %Rectangle{}

      assert Rectangle.valid?(rectangle) == false

      rectangle = rectangle_fixture()

      assert Rectangle.valid?(rectangle) == true
    end
  end
end
