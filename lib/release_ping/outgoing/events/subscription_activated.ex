defmodule ReleasePing.Outgoing.Events.SubscriptionActivated do
  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          callback_url: String.t(),
          secret: String.t(),
          topics: [String.t()],
          priority: non_neg_integer
        }

  defstruct uuid: nil,
            name: nil,
            callback_url: nil,
            secret: nil,
            topics: [],
            priority: 10
end
