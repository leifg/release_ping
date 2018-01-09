defmodule ReleasePing.Outgoing.Events.NotificationSucceeded do
  alias ReleasePing.Outgoing.Events.NotificationSucceeded

  require Logger

  @type t :: %__MODULE__{
          uuid: String.t(),
          message: String.t(),
          signature: String.t(),
          attempt: non_neg_integer,
          http_response: ReleasePing.Outgoing.Aggregates.Subscription.notification_http_response()
        }

  defstruct uuid: nil,
            message: nil,
            signature: nil,
            attempt: 1,
            http_response: %{}

  defimpl Commanded.Serialization.JsonDecoder, for: NotificationSucceeded do
    def decode(event) do
      %NotificationSucceeded{event | http_response: map_http_response(event.http_response)}
    end

    defp map_http_response(%{"status_code" => status_code}) do
      %{
        status_code: status_code
      }
    end

    defp map_http_response(unknown) do
      Logger.warn(["Non parsable HTTP Resonse: ", inspect(unknown)])
    end
  end
end
