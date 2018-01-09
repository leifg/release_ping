defmodule ReleasePing.Outgoing.Commands.NotifySubscriber do
  @type t :: %__MODULE__{
          uuid: String.t(),
          release_uuid: String.t(),
          subscription_uuid: String.t(),
          session_uuid: String.t(),
          attempt: non_neg_integer,
          payload: ReleasePing.Outgoing.Aggregates.Subscription.notification_payload()
        }

  defstruct uuid: nil,
            release_uuid: nil,
            subscription_uuid: nil,
            session_uuid: nil,
            attempt: 1,
            payload: %{}
end
