defmodule PaintingAppWeb.CanvasLive do
  use PaintingAppWeb, :live_view
  alias PaintingApp.PaintingStore

  @topic "painting"

  def mount(_params, _session, socket) do
    canvas_id = Ecto.UUID.generate()

    random_all_color_canvas =
      1..10
      |> Enum.to_list()
      |> Enum.map(fn _row ->
        Enum.to_list(1..10)
        |> Enum.map(fn _col ->
          %PaintingAppWeb.Pixel{
            hex: ["#a3a3a3", "#000000", "#FFFFFF", "#f2f3fg"] |> Enum.shuffle() |> Enum.take(1)
          }
        end)
      end)

    # this shows new connections in black and white
    # but keeps the existing ones colored nicely with
    # bright colors when people click generate
    # however, because mount runs twice it broadcasts
    # a blank one that we cant do much about, so we
    # are just leaving that as an artistic touch
    # commenting this out will make it so that when
    # we get a new connection we dont immediately see
    # the black and white board

    #   Phoenix.PubSub.broadcast(
    #     PaintingApp.PubSub,
    #     @topic,
    #     {:canvas_updated, canvas_id, random_all_color_canvas}
    #   )

    # persist teh canvas to the ETS cache
    PaintingStore.put_canvas(
      canvas_id,
      random_all_color_canvas
    )

    # Assign the canvas data and canvas_id in the UI
    socket =
      socket
      |> assign(:canvas_id, canvas_id)
      |> assign(:canvas, random_all_color_canvas)

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
            <td style={style_for(pixel.hex)}></td>
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
        # yields 0..12
        for _ <- 1..10, do: :rand.uniform(13) - 1
      end
      |> Enum.map(fn row ->
        Enum.map(row, fn n -> %PaintingAppWeb.Pixel{hex: color_for(n)} end)
      end)

    socket = assign(socket, :canvas, new_canvas)

    Phoenix.PubSub.broadcast(
      PaintingApp.PubSub,
      @topic,
      {:canvas_updated, socket.assigns.canvas_id, new_canvas}
    )

    {:noreply, socket}
  end

  # white
  defp color_for(nil), do: "#FFFFFF"
  # bright red
  defp color_for(0), do: "#FF0000"
  # orange
  defp color_for(1), do: "#FF7F00"
  # yellow
  defp color_for(2), do: "#FFFF00"
  # lime
  defp color_for(3), do: "#00FF00"
  # cyan
  defp color_for(4), do: "#00FFFF"
  # azure
  defp color_for(5), do: "#007FFF"
  # blue
  defp color_for(6), do: "#0000FF"
  # violet
  defp color_for(7), do: "#7F00FF"
  # magenta
  defp color_for(8), do: "#FF00FF"
  # hot magenta-pink
  defp color_for(9), do: "#FF0080"
  # hotpink
  defp color_for(10), do: "#FF69B4"
  # pink
  defp color_for(11), do: "#FFC0CB"
  # gold
  defp color_for(12), do: "#FFD700"

  defp style_for(hex) do
    "width: 10px; height: 10px; background-color: #{hex};"
  end
end
