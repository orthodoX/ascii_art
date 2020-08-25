defmodule AsciiArt.DrawingsTest do
  use AsciiArt.DataCase

  alias AsciiArt.Drawings

  describe "canvases" do
    alias AsciiArt.Drawings.Canvas

    @valid_attrs %{drawing: "some drawing"}
    @update_attrs %{drawing: "some updated drawing"}
    @invalid_attrs %{drawing: nil}

    def canvas_fixture(attrs \\ %{}) do
      {:ok, canvas} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Drawings.create_canvas()

      canvas
    end

    test "list_canvases/0 returns all canvases" do
      canvas = canvas_fixture()
      assert Drawings.list_canvases() == [canvas]
    end

    test "get_canvas!/1 returns the canvas with given id" do
      canvas = canvas_fixture()
      assert Drawings.get_canvas!(canvas.id) == canvas
    end

    test "create_canvas/1 with valid data creates a canvas" do
      assert {:ok, %Canvas{} = canvas} = Drawings.create_canvas(@valid_attrs)
      assert canvas.drawing == "some drawing"
    end

    test "create_canvas/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Drawings.create_canvas(@invalid_attrs)
    end

    test "update_canvas/2 with valid data updates the canvas" do
      canvas = canvas_fixture()
      assert {:ok, %Canvas{} = canvas} = Drawings.update_canvas(canvas, @update_attrs)
      assert canvas.drawing == "some updated drawing"
    end

    test "update_canvas/2 with invalid data returns error changeset" do
      canvas = canvas_fixture()
      assert {:error, %Ecto.Changeset{}} = Drawings.update_canvas(canvas, @invalid_attrs)
      assert canvas == Drawings.get_canvas!(canvas.id)
    end

    test "delete_canvas/1 deletes the canvas" do
      canvas = canvas_fixture()
      assert {:ok, %Canvas{}} = Drawings.delete_canvas(canvas)
      assert_raise Ecto.NoResultsError, fn -> Drawings.get_canvas!(canvas.id) end
    end

    test "change_canvas/1 returns a canvas changeset" do
      canvas = canvas_fixture()
      assert %Ecto.Changeset{} = Drawings.change_canvas(canvas)
    end
  end

  alias AsciiArt.Drawings.Rectangle

  describe "draw_canvas/1" do
    test "draws canvas with multiple drawings when no overlapping" do
      rectangles = [
        %Rectangle{coordinates: [3, 2], width: 5, height: 3, outline: "@", fill: "X"},
        %Rectangle{coordinates: [10, 3], width: 14, height: 6, outline: "X", fill: "O"}
      ]

      assert Drawings.draw_canvas(rectangles) |> String.trim() ==
               """

                  @@@@@
                  @XXX@  XXXXXXXXXXXXXX
                  @@@@@  XOOOOOOOOOOOOX
                         XOOOOOOOOOOOOX
                         XOOOOOOOOOOOOX
                         XOOOOOOOOOOOOX
                         XXXXXXXXXXXXXX
               """
               |> String.trim()
    end

    test "draws canvas with multiple drawings when some overlapping" do
      rectangles = [
        %Rectangle{coordinates: [14, 0], width: 7, height: 6, outline: "none", fill: "."},
        %Rectangle{coordinates: [0, 3], width: 8, height: 4, outline: "O", fill: "none"},
        %Rectangle{coordinates: [5, 5], width: 5, height: 3, outline: "X", fill: "X"}
      ]

      assert Drawings.draw_canvas(rectangles) |> String.trim() ==
               """
                             .......
                             .......
                             .......
               OOOOOOOO      .......
               O      O      .......
               O    XXXXX    .......
               OOOOOXXXXX
                    XXXXX
               """
               |> String.trim()
    end
  end
end
