defmodule PaintingAppWeb.CanvasLive do
  use PaintingAppWeb, :live_view

  @topic "painting"

  def mount(_params, _session, socket) do
    canvas_id = Ecto.UUID.generate()
    random_all_color_canvas =
      1..10
      |> Enum.to_list
      |> Enum.map(fn(_row) ->
        Enum.to_list(1..10)
        |> Enum.map(fn(_col) -> %PaintingAppWeb.Pixel{hex: ["#a3a3a3", "#000000", "#FFFFFF", "#f2f3fg"] |> Enum.shuffle |> Enum.take(1)} end)
      end)

    # this shows new connections in black and white
    # but keeps the existing ones colored nicely with
    # bright colors when people click generate
    # however, because mount runs twice it broadcasts
    # a blank one that we cant do much about, so we
    # are just leaving that as an artistic touch
    Phoenix.PubSub.broadcast(
      PaintingApp.PubSub,
      @topic,
      {:canvas_updated, canvas_id, random_all_color_canvas}
    )

    # Assign the canvas data and canvas_id
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

  defp random_hex_color do
    # Generate a random color in the #RRGGBB range
    "#" <> Integer.to_string(:rand.uniform(0xFFFFFF), 16)
    |> String.pad_trailing(7, "0")  # Just to ensure 6 digits
  end

  def random_greyscale_hex do
    # Grab a random number from 0 to 255
    val = :rand.uniform(256) - 1

    # Convert it to a 2-digit hex string (e.g., "00", "7f", "ff")
    hex_val = val |> Integer.to_string(16) |> String.pad_leading(2, "0")

    # Use the same hex substring for R, G, and B
    "#{hex_val}#{hex_val}#{hex_val}"
  end

  defp style_for(hex) do
    "width: 10px; height: 10px; background-color: #{hex};"
  end
end
