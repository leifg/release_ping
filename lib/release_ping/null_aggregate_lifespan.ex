defmodule ReleasePing.NullAggregateLifespan do
  @behaviour Commanded.Aggregates.AggregateLifespan

  def after_event(_event), do: 0
end
