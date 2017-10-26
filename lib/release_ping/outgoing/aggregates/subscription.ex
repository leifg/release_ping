defmodule ReleasePing.Outgoing.Aggregates.Subscription do
  alias ReleasePing.Outgoing.Aggregates.Subscription
  alias ReleasePing.Outgoing.Commands.{AddTrustedSubscription, NotifySubscriber}
  alias ReleasePing.Outgoing.Events.{NotificationFailed, NotificationSucceeded, SubscriptionActivated}
  alias ReleasePing.Outgoing.Utils.WebhookClient

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    callback_url: String.t,
    secret: String.t,
    topics: [String.t],
    priority: non_neg_integer,
  }

  @type notification_payload :: %{
    uuid: String.t,
    software: %{
      uuid: String.to_existing_atom,
      type: ReleasePing.Core.Aggregates.Software.type,
      slug: String.t,
      name: String.t,
    },
    version_string: String.t,
    published_at: String.t,
    release_notes_url: String.t,
    version_info: %{
      major: non_neg_integer,
      minor: non_neg_integer,
      patch: non_neg_integer,
      pre_release: String.t,
    }
  }

  @type notification_http_response :: %{
    status_code: non_neg_integer,
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

  @doc """
  Notifies a subscriber
  """
  def execute(%Subscription{} = subscription, %NotifySubscriber{} = notify) do
    message = Poison.encode!(notify.payload)
    signature = message_signature(message, subscription.secret)
    status_code = case WebhookClient.notify(subscription.callback_url, message, signature, notify) do
      {:ok, %{status: status}} -> status
      {:error, _} -> -1
    end

    cond do
      status_code == -1 -> notification_failed(notify, message, signature, status_code)
      status_code < 300 -> notification_succeeded(notify, message, signature, status_code)
      true -> notification_failed(notify, message, signature, status_code)
    end
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

  def apply(%Subscription{} = subscription, %NotificationSucceeded{}) do
    subscription
  end

  def apply(%Subscription{} = subscription, %NotificationFailed{}) do
    subscription
  end

  defp message_signature(message, secret) do
    signature = :crypto.hmac(:sha256, secret, message) |> Base.encode16() |> String.downcase()
    "sha256=#{signature}"
  end

  defp notification_succeeded(notify_command, message, signature, status_code) do
    %NotificationSucceeded{
      uuid: notify_command.uuid,
      message: message,
      signature: signature,
      http_response: %{
        status_code: status_code,
      },
    }
  end

  defp notification_failed(notify_command, message, signature, status_code) do
    %NotificationFailed{
      uuid: notify_command.uuid,
      message: message,
      signature: signature,
      http_response: %{
        status_code: status_code,
      },
    }
  end
end
