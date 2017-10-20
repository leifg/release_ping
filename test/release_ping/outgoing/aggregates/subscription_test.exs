defmodule ReleasePing.Outgoing.Aggregates.SubscriptionTest do
  alias ReleasePing.Outgoing.Aggregates.Subscription
  alias ReleasePing.Outgoing.Commands.AddTrustedSubscription
  alias ReleasePing.Outgoing.Events.SubscriptionActivated

  use ReleasePing.AggregateCase, aggregate: Subscription

  describe "add trusted subscription" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()

      command = %AddTrustedSubscription{
        uuid: uuid,
        name: "Test Subscription",
        callback_url: "https://leifg.ngrok.io",
        secret: "AtA6b2htZzp2IrgZ5so9",
        topics: ["language:erlang"],
        priority: 0,
      }

      assert_events(%Subscription{}, command, [
        %SubscriptionActivated{
          uuid: uuid,
          name: "Test Subscription",
          callback_url: "https://leifg.ngrok.io",
          secret: "AtA6b2htZzp2IrgZ5so9",
          topics: ["language:erlang"],
          priority: 0,
        }
      ])
    end
  end
end
