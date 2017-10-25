defmodule ReleasePing.Outgoing.Aggregates.SubscriptionTest do
  alias ReleasePing.Outgoing.Aggregates.Subscription
  alias ReleasePing.Outgoing.Commands.{AddTrustedSubscription, NotifySubscriber}
  alias ReleasePing.Outgoing.Events.{NotificationFailed, NotificationSucceeded, SubscriptionActivated}

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

  describe "notify subscriber" do
    setup do
      bypass = Bypass.open

      release_uuid = "e1c9d520-9cea-4dc9-88ff-8591fcf7e9b1"
      software_uuid = "c1c538c8-fa14-46c2-989c-2a2e65160670"

      payload = %{
        uuid: release_uuid,
        software: %{
          uuid: software_uuid,
          type: :language,
          slug: "elixir",
          name: "Elixir"
        },
        version_string: "v1.5.2",
        published_at: "2017-09-29T12:10:47Z",
        version_info: %{
          major: 1,
          minor: 5,
          patch: 2,
          pre_release: nil,
        }
      }

      notify_uuid = UUID.uuid4()
      session_uuid = UUID.uuid4()

      subscription_added_event = %SubscriptionActivated{
        uuid: UUID.uuid4(),
        name: "Test Subscription",
        callback_url: "http://localhost:#{bypass.port}",
        secret: "AtA6b2htZzp2IrgZ5so9",
        topics: ["language:erlang"],
        priority: 0,
      }

      aggregate = evolve(subscription_added_event)

      notify_subscriber_command = %NotifySubscriber{
        uuid: notify_uuid,
        subscription_uuid: subscription_added_event.uuid,
        session_uuid: session_uuid,
        release_uuid: release_uuid,
        attempt: 1,
        payload: payload,
      }

      context = %{
        bypass: bypass,
        aggregate: aggregate,
        signature: "sha256=9f482c7f1534ce02115a978642a20bf15505eba5d56942f99ea4e4508ee6c0f7",
        subscription_added_event: subscription_added_event,
        notify_subscriber_command: notify_subscriber_command,
      }

      {:ok, context}
    end

    test "succeeds with correct endpoint", %{bypass: bypass, aggregate: aggregate, signature: signature, subscription_added_event: subscription_added_event, notify_subscriber_command: notify_subscriber_command} do
      Bypass.expect bypass, "POST", "/", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == Poison.encode!(notify_subscriber_command.payload)
        assert Plug.Conn.get_req_header(conn, "x-rp-webhook-uuid") == [notify_subscriber_command.uuid]
        assert Plug.Conn.get_req_header(conn, "x-rp-webhook-subscription-id") == [subscription_added_event.uuid]
        assert Plug.Conn.get_req_header(conn, "x-rp-webhook-session-id") == [notify_subscriber_command.session_uuid]
        assert Plug.Conn.get_req_header(conn, "x-rp-webhook-attempt") == ["1"]
        assert Plug.Conn.get_req_header(conn, "x-rp-webhook-signature") == [signature]
        Plug.Conn.resp(conn, 200, "")
      end

      assert_events(aggregate, notify_subscriber_command, [
        %NotificationSucceeded{
          uuid: notify_subscriber_command.uuid,
          message: Poison.encode!(notify_subscriber_command.payload),
          signature: signature,
          attempt: 1,
          http_response: %{
            status_code: 200,
          },
        }
      ])
    end

    test "fails with 500 endpoint", %{bypass: bypass, aggregate: aggregate, signature: signature, notify_subscriber_command: notify_subscriber_command} do
      Bypass.expect bypass, "POST", "/", fn conn ->
        Plug.Conn.resp(conn, 500, "")
      end

      assert_events(aggregate, notify_subscriber_command, [
        %NotificationFailed{
          uuid: notify_subscriber_command.uuid,
          message: Poison.encode!(notify_subscriber_command.payload),
          signature: signature,
          attempt: 1,
          http_response: %{
            status_code: 500,
          },
        }
      ])
    end

    test "fails with connection reset", %{bypass: bypass, aggregate: aggregate, signature: signature, notify_subscriber_command: notify_subscriber_command} do
      Bypass.down(bypass)

      assert_events(aggregate, notify_subscriber_command, [
        %NotificationFailed{
          uuid: notify_subscriber_command.uuid,
          message: Poison.encode!(notify_subscriber_command.payload),
          signature: signature,
          attempt: 1,
          http_response: %{
            status_code: -1,
          },
        }
      ])
    end
  end
end
