defmodule JourDashWeb.Live.Components.TC.TripMap do
  @moduledoc false

  use JourDashWeb, :html

  def render(assigns) do
    ~H"""
    <div id={"trip-map-#{@trip}-id"}>
      <div>
        <%= for i <- 0..@trip_values.location_dropoff do %>
          <%= cond do %>
            <% i == @trip_values.location_pickup and @trip_values.picked_up? == true -> %>
              <span class="font-mono text-lg">🧑🏼‍🍳</span>
            <% i == @trip_values.location_pickup -> %>
              <span class="font-mono text-lg">{@trip_values.item_to_deliver}</span>
            <% i == @trip_values.location_dropoff and @trip_values.handed_off? == true -> %>
              <span class="font-mono text-lg">{@trip_values.item_to_deliver}</span>
            <% i == @trip_values.location_dropoff and @trip_values.dropped_off? == true -> %>
              <span class="font-mono text-lg">{@trip_values.item_to_deliver}</span>
            <% i == @trip_values.location_dropoff -> %>
              <span class="font-mono text-lg">🏠</span>
            <% true -> %>
              <span class="font-mono text-lg">&nbsp;</span>
          <% end %>
        <% end %>
      </div>
      <div>
        <%= for i <- 0..@trip_values.location_dropoff do %>
          <%= cond do %>
            <% i == @trip_values.location_driver and @trip_values.current_activity == "driving_to_pickup" -> %>
              <span class="font-mono text-lg animate-pulse inline-block -scale-x-100">🚗</span>
            <% i == @trip_values.location_driver and @trip_values.current_activity == "waiting_for_item" -> %>
              <span class="font-mono text-lg animate-pulse">⌛️</span>
            <% i == @trip_values.location_driver and @trip_values.current_activity == "driving_to_dropoff" -> %>
              <span class="font-mono text-lg animate-pulse">{@trip_values.item_to_deliver}</span>
            <% i == @trip_values.location_pickup and @trip_values.picked_up? == true  -> %>
              <span class="font-mono text-lg">✅</span>
            <% i == @trip_values.location_dropoff and @trip_values.dropped_off? == true  -> %>
              <span class="font-mono text-lg">📦</span>
            <% i == @trip_values.location_dropoff and @trip_values.handed_off? == true  -> %>
              <span class="font-mono text-lg">💁</span>
            <% i == @trip_values.location_dropoff and @trip_values.current_activity == "waiting_for_customer"  -> %>
              <span class="font-mono text-lg animate-pulse">⌛️</span>
            <% i < @trip_values.location_driver -> %>
              <span class="font-mono text-lg text-success">●</span>
            <% i > @trip_values.location_driver -> %>
              <span class="font-mono text-lg">○</span>
            <% true -> %>
              <span class="font-mono text-lg text-success">●</span>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
