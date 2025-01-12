defmodule PaintingAppWeb.PaintingLive do
  use PaintingAppWeb, :live_view

  @topic "painting"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PaintingApp.PubSub, @topic)
    end

    # We'll keep a map of canvas_id => 10x10 data
    socket = assign(socket, :canvases, %{})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>All Canvases</h2>
    <div>
      <%= for {_canvas_id, canvas_data} <- @canvases do %>
        <table>
          <%= for row <- canvas_data do %>
            <tr>
              <%= for pixel <- row do %>
                <td style={style_for(pixel)}>
                </td>
              <% end %>
            </tr>
          <% end %>
        </table>
      <% end %>
    </div>
    """
  end

  # Receives broadcast from any CanvasLive
  def handle_info({:canvas_updated, canvas_id, new_canvas}, socket) do
    socket =
      update(socket, :canvases, fn canvases ->
        Map.put(canvases, canvas_id, new_canvas)
      end)

    {:noreply, socket}
  end

  defp color_for(nil), do: "#FFFFFF"
  defp color_for(0), do: "#FF0000"
  defp color_for(1), do: "#000000"

  defp style_for(pixel) do
    "width: 10px; height: 10px; background-color: #{color_for(pixel)};"
  end
end

