defmodule JourDash.Helpers do
  @moduledoc false

  def to_datetime_string_compact(unix_timestamp, time_zone) do
    unix_timestamp
    |> DateTime.from_unix!()
    |> DateTime.shift_zone!(time_zone)
    |> Calendar.strftime("%Y%m%d %H:%M:%S")
  end
end
