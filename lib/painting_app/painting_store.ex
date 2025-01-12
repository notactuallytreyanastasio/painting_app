defmodule PaintingApp.PaintingStore do
  @moduledoc """
  A simple GenServer that manages a named ETS table for storing canvas data.
  Each canvas_id maps to a 10×10 array of pixel data (or whatever structure you want).
  """

  use GenServer

  @table :painting_ets
  @topic "painting"

  ## Public API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Insert or update a canvas, then broadcast to the "painting" topic.
  """
  def put_canvas(canvas_id, canvas_data) do
    :ets.insert(@table, {canvas_id, canvas_data})

    # Let everyone else (PaintingLive, etc.) know this canvas changed
    Phoenix.PubSub.broadcast(PaintingApp.PubSub, @topic, {:canvas_updated, canvas_id, canvas_data})
  end

  @doc """
  Return the 10×10 for a given canvas_id, or nil if not found.
  """
  def get_canvas(canvas_id) do
    case :ets.lookup(@table, canvas_id) do
      [{^canvas_id, data}] -> data
      [] -> nil
    end
  end

  @doc """
  Returns a map of canvas_id => canvas_data for all known canvases in ETS.
  """
  def all_canvases do
    :ets.tab2list(@table)
    |> Enum.into(%{}, fn {key, val} -> {key, val} end)
  end

  ## GenServer Callbacks

  @impl true
  def init(:ok) do
    # Create a named, public ETS table
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    {:ok, nil}
  end
end

