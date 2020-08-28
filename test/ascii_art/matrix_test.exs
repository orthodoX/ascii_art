defmodule AsciiArt.MatrixTest do
  use AsciiArt.DataCase, async: true

  alias AsciiArt.Matrix

  describe "helper functions" do
    test "from_list/1 creates a map matrix from a list" do
      assert Matrix.from_list([["x", "o", "x"]]) == %{0 => %{0 => "x", 1 => "o", 2 => "x"}}
    end

    test "to_list/1 creates a list from a map matrix" do
      assert Matrix.to_list(%{0 => %{0 => "x", 1 => "o", 2 => "x"}}) == [["x", "o", "x"]]
    end
  end
end
