defmodule JourDash.Trip.PubSubNotifications do
  @moduledoc """
  This module defines functions that generate PubSub notifications upon
  updates to various graph nodes.
  """

  require Logger

  def broadcast_current_activity_update(trip_id, {:ok, new_activity}) do
    Logger.debug("#{trip_id}: current_activity updated, new activity: #{new_activity}")

    Phoenix.PubSub.broadcast(
      JourDash.PubSub,
      "current_activity_update_#{trip_id}",
      {:activity_changed, trip_id, new_activity}
    )

    {:ok, "new activity notified"}
  end

  def broadcast_trip_completed(trip_id, {:ok, trip_completed_at}) do
    Logger.debug("[#{trip_id}] trip_completed_at: #{trip_completed_at}")

    Phoenix.PubSub.broadcast(
      JourDash.PubSub,
      "trip_completed",
      {:trip_completed, trip_id}
    )

    {:ok, "trip_completed_at notification sent"}
  end

  def broadcast_trip_history_update(
        trip_id,
        {:ok, [%{"node" => node, "value" => value} | _older_history]} =
          updated_history
      ) do
    Logger.info("[#{trip_id}]: trip_history updated: #{node}: #{inspect(value)}")

    Phoenix.PubSub.broadcast(
      JourDash.PubSub,
      "history_update_#{trip_id}",
      {:history_changed, trip_id, updated_history}
    )

    {:ok, "trip_history_updated"}
  end
end
