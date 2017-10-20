defmodule ReleasePing.Outgoing.Projectors.ActiveSubscriptionTest do
  alias ReleasePing.Outgoing.ActiveSubscription
  alias ReleasePing.Outgoing.Events.SubscriptionActivated
  alias ReleasePing.{Core, Repo}

  use ReleasePing.DataCase

  describe "ActiveSubscription Read Model SubscriptionActivated" do
    setup [:add_software]

    test "correctly creates an entry in the read model", %{software: [erlang, elixir]} do
      subscription_uuid = UUID.uuid4()

      event = %SubscriptionActivated{
        uuid: subscription_uuid,
        name: "Test Subscription",
        callback_url: "https://leifg.ngrok.io",
        secret: "AtA6b2htZzp2IrgZ5so9",
        topics: ["language:erlang", "language:elixir"],
        priority: 0,
      }

      ReleasePing.Outgoing.Projectors.ActiveSubscription.handle(event, %{stream_version: 1, event_number: 1})

      expected_rows = [
        %ActiveSubscription{
          uuid: subscription_uuid,
          name: "Test Subscription",
          callback_url: "https://leifg.ngrok.io",
          stream_version: 1,
          priority: 0,
          topic: "erlang",
          type: :language,
          software_uuid: erlang.uuid,
        },
        %ActiveSubscription{
          uuid: subscription_uuid,
          name: "Test Subscription",
          callback_url: "https://leifg.ngrok.io",
          stream_version: 1,
          priority: 0,
          topic: "elixir",
          type: :language,
          software_uuid: elixir.uuid,
        },
      ]

      rows = Repo.all(ActiveSubscription, uuid: subscription_uuid)

      assert length(rows) == 2

      Enum.zip(rows, expected_rows) |> Enum.each(fn({row, expected_row}) ->
        assert row.uuid == expected_row.uuid
        assert row.name == expected_row.name
        assert row.callback_url == expected_row.callback_url
        assert row.priority == expected_row.priority
        assert row.topic == expected_row.topic
        assert row.type == expected_row.type
        assert row.software_uuid == expected_row.software_uuid
      end)
    end
  end


  defp add_software(_context) do
    assert {:ok, erlang} = Core.add_software(build(:erlang))
    assert {:ok, elixir} = Core.add_software(build(:elixir))

    {:ok, software: [erlang, elixir]}
  end
end
