defmodule ReleasePing.Conversion do
  def from_iso8601_to_naive_datetime(nil), do: nil

  def from_iso8601_to_naive_datetime(date_input) do
    NaiveDateTime.from_iso8601!(date_input)
  end
end
