defmodule ReleasePing.Wait do
  @default_timeout 5_000
  @default_retry_interval 50

  def until(fun), do: until(@default_timeout, fun)

  def until(0, fun) do
    case fun.() do
      result when result in [nil, false] -> {:error, :timeout}
      true -> :ok
      result -> {:ok, result}
    end
  end

  def until(timeout, fun) do
    case fun.() do
      result when result in [nil, false] ->
        :timer.sleep(@default_retry_interval)
        until(max(0, timeout - @default_retry_interval), fun)

      true ->
        :ok

      result ->
        {:ok, result}
    end
  end
end
