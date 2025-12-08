defmodule JourDashWeb.Live.Home.Index do
  @moduledoc false
  use JourDashWeb, :live_view

  alias JourDashWeb.Live.Components

  require Logger

  def mount(params, session, socket) do
    connected? = connected?(socket)

    time_zone =
      socket
      |> get_connect_params()
      |> case do
        nil -> nil
        params -> Map.get(params, "time_zone")
      end

    socket =
      assign(socket, :connected?, connected?)
      |> assign(:time_zone, time_zone)
      |> assign(:view_analytics, false)
      |> mount_with_connected(params, session, connected?)

    {:ok, socket}
  end

  defp load_quick_analytics(socket) do
    graph = JourDash.Trip.Graph.new()

    trip_count_dropped_off =
      Journey.count_executions(graph_name: graph.name, filter_by: [{:dropped_off?, :eq, true}])

    trip_count_handed_off =
      Journey.count_executions(graph_name: graph.name, filter_by: [{:handed_off?, :eq, true}])

    trip_count_in_progress =
      Journey.count_executions(
        graph_name: graph.name,
        filter_by: [{:dropped_off?, :is_not_set}, {:handed_off?, :is_not_set}]
      )

    socket =
      socket
      |> assign(:trip_count_dropped_off, trip_count_dropped_off)
      |> assign(:trip_count_handed_off, trip_count_handed_off)
      |> assign(:trip_count_in_progress, trip_count_in_progress)

    socket
  end

  defp load_full_analytics(socket) do
    graph = JourDash.Trip.Graph.new()
    analytics_data = Journey.Insights.FlowAnalytics.flow_analytics(graph.name, graph.version)

    nodes_map =
      analytics_data.node_stats.nodes
      |> Enum.map(fn node -> {node.node_name, node} end)
      |> Enum.into(%{})

    analytics_data = Map.put(analytics_data, :nodes_map, nodes_map)
    analytics_text = Journey.Insights.FlowAnalytics.to_text(analytics_data)

    socket =
      socket
      |> assign(:analytics_data, analytics_data)
      |> assign(:analytics_text, analytics_text)

    socket
  end

  defp load_trips(socket) do
    Logger.debug("Loading trips")

    graph = JourDash.Trip.Graph.new()

    trips_in_progress =
      Journey.list_executions(
        graph_name: graph.name,
        sort_by: [created_at: :desc],
        filter_by: [{:dropped_off?, :is_not_set}, {:handed_off?, :is_not_set}],
        limit: 100
      )

    trips_any =
      Journey.list_executions(
        graph_name: graph.name,
        sort_by: [created_at: :desc],
        limit: 100
      )

    all_trips =
      (trips_in_progress ++ trips_any)
      |> Enum.uniq_by(& &1.id)
      |> Enum.sort_by(fn e -> value_of(e, :created_at) end, :desc)

    trip_ids =
      all_trips
      |> Enum.map(fn execution -> execution.id end)

    socket
    |> assign(trips: trip_ids)
  end

  defp value_of(execution, key) do
    execution.values |> Enum.find(fn v -> v.node_name == key end) |> Map.get(:node_value)
  end

  def mount_with_connected(socket, _params, _session, connected?) when connected? == true do
    Logger.debug("Connected to LiveView")
    :ok = Phoenix.PubSub.subscribe(JourDash.PubSub, "new_trips")
    :ok = Phoenix.PubSub.subscribe(JourDash.PubSub, "trip_completed")

    socket
    |> load_trips()
    |> load_quick_analytics()
    |> load_full_analytics()
    |> assign(:newly_created_trip_id, nil)
  end

  def mount_with_connected(socket, _params, _session, connected?) when connected? == false do
    Logger.debug("Not connected to LiveView")

    socket
    |> assign(trips: [])
    |> assign(:newly_created_trip_id, nil)
  end

  def handle_event("on-toggle-view-analytics-click" = event, _params, socket) do
    Logger.info(event)

    socket =
      socket
      |> assign(:view_analytics, not socket.assigns.view_analytics)

    {:noreply, socket}
  end

  def handle_event("on_start_trip_button_click", _params, socket) do
    Logger.info("Starting trip")

    trip = JourDash.Trip.start()

    :ok = Phoenix.PubSub.broadcast(JourDash.PubSub, "new_trips", {:trip_created, trip.id})

    socket =
      socket
      |> assign(:newly_created_trip_id, trip.id)

    {:noreply, socket}
  end

  def handle_info({:trip_completed, trip_id}, socket) do
    Logger.debug("#{trip_id} Handling trip_completed")
    socket = socket |> load_quick_analytics() |> load_trips()
    {:noreply, socket}
  end

  def handle_info({:trip_created, trip}, socket) do
    Logger.debug("#{trip}: Handling trip creation")
    trip_count_in_progress = socket.assigns.trip_count_in_progress + 1

    trips =
      if socket.assigns.trips |> Enum.member?(trip),
        do: socket.assigns.trips,
        else: [trip | socket.assigns.trips]

    socket =
      socket
      |> assign(trip_count_in_progress: trip_count_in_progress)
      |> assign(trips: trips)

    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.info("Terminating Live.Home (reason: #{inspect(reason)})")
    :ok
  end

  def drivers_available(), do: 5
end
