defmodule PaintingAppWeb.PaintingLive do
  use PaintingAppWeb, :live_view
  alias PaintingAppWeb.CanvasComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PaintingApp.PubSub, "painting")
    end

    # We'll store canvases in a map: canvas_id => 10x10 data
    socket = assign(socket, :canvases, %{})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>All Canvases</h2>
    <div style="display: flex; flex-wrap: wrap;">
      <%= for {canvas_id, canvas_data} <- @canvases do %>
        <.live_component
          module={CanvasComponent}
          id={canvas_id}
          canvas={canvas_data} />
      <% end %>
    </div>
    """
  end

  # This is where we receive notifications that a particular canvas has changed
  def handle_info({:canvas_updated, canvas_id, new_canvas}, socket) do
    socket =
      update(socket, :canvases, fn canvases ->
        Map.put(canvases, canvas_id, new_canvas)
      end)

    {:noreply, socket}
  end
end
