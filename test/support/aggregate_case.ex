defmodule ReleasePing.AggregateCase do
  @moduledoc """
  This module defines the test case to be used by aggregate tests.
  """

  use ExUnit.CaseTemplate

  using [aggregate: aggregate] do
    quote bind_quoted: [aggregate: aggregate] do
      @aggregate aggregate

      import ReleasePing.Factory

      # assert that the expected events are returned when the given commands have been executed
      defp assert_events(commands, expected_events) do
        assert_events(%@aggregate{}, commands, expected_events)
      end

      defp assert_events(aggregate, commands, assertion_fun) when is_function(assertion_fun) do
        {aggregate, events, error} = execute(commands, aggregate)

        assertion_fun.(aggregate, events, error)
      end

      defp assert_events(aggregate, commands, expected_events) do
        assertion_fun = fn(_predicate_aggregate, predicate_events, predicate_error) ->
          assert is_nil(predicate_error)
          assert List.wrap(predicate_events) == expected_events
        end

        assert_events(aggregate, commands, assertion_fun)
      end

      defp assert_error(commands, expected_error) do
        assert_error(%@aggregate{}, commands, expected_error)
      end

      defp assert_error(aggregate, commands, expected_error) do
        assertion_fun = fn(_predicate_aggregate, predicate_events, predicate_error) ->
          assert predicate_error == expected_error
        end

        assert_events(aggregate, commands, assertion_fun)
      end

      # execute one or more commands against an aggregate
      defp execute(commands, aggregate \\ %@aggregate{})
      defp execute(commands, aggregate) do
        commands
        |> List.wrap()
        |> Enum.reduce({aggregate, [], nil}, fn
          (command, {aggregate, _events, nil}) ->
            case @aggregate.execute(aggregate, command) do
              {:error, reason} = error -> {aggregate, nil, error}
              events -> {evolve(aggregate, events), events, nil}
            end
          (command, {aggregate, _events, _error} = reply) -> reply
        end)
      end

      # apply the given events to the aggregate state
      defp evolve(events) do
        evolve(%@aggregate{}, events)
      end

      defp evolve(aggregate, events) do
        events
        |> List.wrap()
        |> Enum.reduce(aggregate, &@aggregate.apply(&2, &1))
      end
    end
  end
end
