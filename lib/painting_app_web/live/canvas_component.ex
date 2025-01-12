# Our pixel struct – optional, you could just store strings
defmodule PaintingAppWeb.Pixel do
  defstruct [:hex]
end


defmodule PaintingAppWeb.CanvasComponent do
  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    # We'll accept either an existing 10x10 or create a new random one if none is passed.
    # The parent can pass `canvas` as a 10x10 list of Pixel structs OR nil, etc.

    canvas =
      case assigns[:canvas] do
        nil -> generate_canvas()       # If no data is passed in, create something fresh
        existing -> existing           # If we have something from the parent, use it
      end

    socket =
      socket
      |> assign(:id, assigns.id)    # Live Components need a unique :id
      |> assign(:canvas, canvas)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3>Canvas <%= @id %></h3>
      <table>
        <%= for row <- @canvas do %>
          <tr>
            <%= for pixel <- row do %>
              <td style={"width: 10px; height: 10px; background-color: #{pixel.hex};"}>
              </td>
            <% end %>
          </tr>
        <% end %>
      </table>
    </div>
    """
  end

  defp generate_canvas do
    for _row <- 1..10 do
      for _col <- 1..10 do
        %PaintingAppWeb.Pixel{hex: random_hex_color()}
      end
    end
  end

  defp random_hex_color do
    # Generate a random color in the #RRGGBB range
    "#" <> Integer.to_string(:rand.uniform(0xFFFFFF), 16)
    |> String.pad_trailing(7, "0")  # Just to ensure 6 digits
  end
end
