defmodule AsciiArtWeb.CanvasController do
  use AsciiArtWeb, :controller

  alias AsciiArt.Drawings
  alias AsciiArt.Drawings.Canvas

  action_fallback AsciiArtWeb.FallbackController

  def index(conn, _params) do
    canvases = Drawings.list_canvases()
    render(conn, "index.json", canvases: canvases)
  end

  def create(conn, %{"canvas" => canvas_params}) do
    with {:ok, %Canvas{} = canvas} <- Drawings.create_canvas(canvas_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.canvas_path(conn, :show, canvas))
      |> render("show.json", canvas: canvas)
    end
  end

  def show(conn, %{"id" => id}) do
    canvas = Drawings.get_canvas!(id)
    render(conn, "show.json", canvas: canvas)
  end

  def update(conn, %{"id" => id, "canvas" => canvas_params}) do
    canvas = Drawings.get_canvas!(id)

    with {:ok, %Canvas{} = canvas} <- Drawings.update_canvas(canvas, canvas_params) do
      render(conn, "show.json", canvas: canvas)
    end
  end

  def delete(conn, %{"id" => id}) do
    canvas = Drawings.get_canvas!(id)

    with {:ok, %Canvas{}} <- Drawings.delete_canvas(canvas) do
      send_resp(conn, :no_content, "")
    end
  end
end
