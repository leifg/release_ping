defmodule ReleasePing.NullAggregateLifespan do
  @behaviour Commanded.Aggregates.AggregateLifespan

  def after_command(_event), do: 0
end
