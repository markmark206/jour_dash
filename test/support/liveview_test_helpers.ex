defmodule JourDashWeb.LiveViewTestHelpers do
  @moduledoc """
  Shared test helpers for LiveView integration tests.
  """

  import Phoenix.LiveViewTest
  require Logger

  @doc """
  Poll for an element to appear within a timeout period.

  Returns true if element appears, false if timeout is reached.

  ## Parameters

    * `view` - The LiveView to poll
    * `element_id` - The DOM ID of the element to search for
    * `timeout_ms` - Maximum time to wait in milliseconds
    * `description` - Description for logging purposes

  ## Examples

      poll_for_element(view, "#my-element-id", 5000, "waiting for element")
  """
  def poll_for_element(view, element_id, timeout_ms, description) do
    deadline = System.monotonic_time(:millisecond) + timeout_ms
    poll_for_element_until(view, element_id, deadline, description)
  end

  defp poll_for_element_until(view, element_id, deadline, description) do
    now = System.monotonic_time(:millisecond)

    if now >= deadline do
      Logger.warning("Timeout reached while #{description}")
      false
    else
      # Trigger a render to get latest state from the LiveView
      render(view)

      if has_element?(view, element_id) do
        true
      else
        # Poll every 500ms
        Process.sleep(500)
        poll_for_element_until(view, element_id, deadline, description)
      end
    end
  end
end
