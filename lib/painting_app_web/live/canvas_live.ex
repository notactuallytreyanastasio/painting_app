defmodule PaintingAppWeb.CanvasLive do
  use PaintingAppWeb, :live_view

  @topic "painting"

  def mount(_params, _session, socket) do
    # Generate a unique ID for this user's canvas
    canvas_id = Ecto.UUID.generate()

    # Create a blank 10x10
    blank_canvas = for _ <- 1..10, do: for(_ <- 1..10, do: nil)

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
            <td style={style_for(pixel)}>
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
        for _ <- 1..10, do: :rand.uniform(2) - 1  # yields 0 or 1
      end

    socket = assign(socket, :canvas, new_canvas)

    Phoenix.PubSub.broadcast(
      PaintingApp.PubSub,
      @topic,
      {:canvas_updated, socket.assigns.canvas_id, new_canvas}
    )

    {:noreply, socket}
  end

  defp color_for(nil), do: "#FFFFFF"
  defp color_for(0), do: "#FF0000"
  defp color_for(1), do: "#000000"

  defp style_for(pixel) do
    "width: 10px; height: 10px; background-color: #{color_for(pixel)};"
  end
end
