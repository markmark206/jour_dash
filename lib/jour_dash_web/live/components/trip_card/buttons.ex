defmodule JourDashWeb.Live.Components.TC.Buttons do
  @moduledoc false

  use JourDashWeb, :html

  def render(assigns) do
    ~H"""
    <div>
      <.button
        :if={
          @trip_values.trip_completed_at == nil and
            @trip_values.current_activity not in ["waiting_for_item", "waiting_for_customer"]
        }
        id={"placeholder-item-#{@trip}-button-id"}
        disabled={true}
        class="invisible btn btn-sm btn-primary my-2 py-2"
      >
        placeholder
      </.button>

      <.button
        :if={@trip_values.current_activity == "waiting_for_item"}
        id={"pickup-item-#{@trip}-button-id"}
        phx-click="on_pickup_item_button_click"
        phx-value-trip={@trip}
        class="btn btn-sm btn-primary my-2 py-2"
      >
        Pick Up
      </.button>
      <.button
        :if={@trip_values.current_activity == "waiting_for_customer"}
        id={"hand-off-item-#{@trip}-button-id"}
        phx-click="on_hand_off_item_button_click"
        phx-value-trip={@trip}
        class="btn btn-sm btn-primary my-2 py-2"
      >
        Hand Off
      </.button>
      <.button
        :if={@trip_values.current_activity == "waiting_for_customer"}
        id={"drop-off-item-#{@trip}-button-id"}
        phx-click="on_drop_off_item_button_click"
        phx-value-trip={@trip}
        class="btn btn-sm btn-primary my-2 py-2"
      >
        Drop Off
      </.button>
    </div>
    """
  end
end
