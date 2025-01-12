defmodule PaintingAppWeb.CanvasLive do
  use PaintingAppWeb, :live_view

  @topic "painting"

  def mount(_params, _session, socket) do
    # Generate a unique ID for this user's canvas
    canvas_id = Ecto.UUID.generate()

    # Create a blank 10x10
    blank_canvas = for _ <- 1..10, do: for(_ <- 1..10, do: %PaintingAppWeb.Pixel{hex: nil})

    # Assign the canvas data and canvas_id
    socket =
      socket
      |> assign(:canvas_id, canvas_id)
      |> assign(:canvas, blank_canvas)

    {:ok, socket}
  end

  def render(assigns) do
    # TODO make this render a canvas component
    ~H"""
    <h2>Your Canvas</h2>
    <button phx-click="generate">Generate Canvas</button>

    <table>
      <%= for row <- @canvas do %>
        <tr>
          <%= for pixel <- row do %>
            <td style={style_for(pixel.hex)}>
            </td>
          <% end %>
        </tr>
      <% end %>
    </table>
    """
  end

  # Handles the "generate" button click, filling the canvas with random 0/1 data
  # and broadcasting it to the painting topic
  def handle_event("generate", _params, socket) do
    new_canvas =
      for _ <- 1..10 do
        for _ <- 1..10, do: :rand.uniform(13) - 1  # yields 0..12
      end
      |> Enum.map(fn(row) ->
        Enum.map(row, fn(n) -> %PaintingAppWeb.Pixel{hex: color_for(n)} end)
      end)

    socket = assign(socket, :canvas, new_canvas)

    Phoenix.PubSub.broadcast(
      PaintingApp.PubSub,
      @topic,
      {:canvas_updated, socket.assigns.canvas_id, new_canvas}
    )

    {:noreply, socket}
  end

  defp color_for(nil), do: "#FFFFFF" # white
  defp color_for(0), do: "#FF0000"   # bright red
  defp color_for(1), do: "#FF7F00"   # orange
  defp color_for(2), do: "#FFFF00"   # yellow
  defp color_for(3), do: "#00FF00"   # lime
  defp color_for(4), do: "#00FFFF"   # cyan
  defp color_for(5), do: "#007FFF"   # azure
  defp color_for(6), do: "#0000FF"   # blue
  defp color_for(7), do: "#7F00FF"   # violet
  defp color_for(8), do: "#FF00FF"   # magenta
  defp color_for(9), do: "#FF0080"   # hot magenta-pink
  defp color_for(10), do: "#FF69B4"  # hotpink
  defp color_for(11), do: "#FFC0CB"  # pink
  defp color_for(12), do: "#FFD700"  # gold

  defp style_for(hex) do
    "width: 10px; height: 10px; background-color: #{hex};"
  end
end
