defmodule ReleasePing.Outgoing.Aggregates.Subscription do
  alias ReleasePing.Outgoing.Aggregates.Subscription
  alias ReleasePing.Outgoing.Commands.AddTrustedSubscription
  alias ReleasePing.Outgoing.Events.SubscriptionActivated

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    callback_url: String.t,
    secret: String.t,
    topics: [String.t],
    priority: non_neg_integer,
  }

  defstruct [
    uuid: nil,
    name: nil,
    callback_url: nil,
    secret: nil,
    topics: [],
    priority: 10,
  ]

  @doc """
  Creates subscription
  """
  def execute(%Subscription{uuid: nil}, %AddTrustedSubscription{} = add) do
    %SubscriptionActivated{
      uuid: add.uuid,
      name: add.name,
      callback_url: add.callback_url,
      secret: add.secret,
      topics: add.topics,
      priority: add.priority,
    }
  end

  # state mutators

  def apply(%Subscription{} = subscription, %SubscriptionActivated{} = added) do
    %Subscription{subscription |
      uuid: added.uuid,
      name: added.name,
      callback_url: added.callback_url,
      secret: added.secret,
      topics: added.topics,
      priority: added.priority,
    }
  end
end
