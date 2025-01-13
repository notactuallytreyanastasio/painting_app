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
    canvas =
      case assigns[:canvas] do
        nil -> generate_canvas()
        existing -> existing
      end

    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:canvas, canvas)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <table>
        <%= for row <- @canvas do %>
          <tr>
            <%= for pixel <- row do %>
              <td style={"width: 10px; height: 10px; background-color: #{pixel.hex};"}></td>
            <% end %>
          </tr>
        <% end %>
      </table>
    </div>
    """
  end

  defp generate_canvas do
    1..10
    |> Enum.to_list()
    |> Enum.map(fn _row ->
      1..10
      |> Enum.to_list()
      |> Enum.map(fn _col ->
        %PaintingAppWeb.Pixel{hex: random_hex_color()}
      end)
    end)
  end

  defp random_hex_color do
    # Generate a random color in the #RRGGBB range
    ("#" <> Integer.to_string(:rand.uniform(0xFFFFFF), 16))
    # Just to ensure 6 digits
    |> String.pad_trailing(7, "0")
  end
end
