defmodule ReleasePing.Outgoing.Events.NotificationFailed do
  alias ReleasePing.Outgoing.Events.NotificationFailed

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

  defimpl Commanded.Serialization.JsonDecoder, for: NotificationFailed do
    def decode(event) do
      %NotificationFailed{event | http_response: map_http_response(event.http_response)}
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
