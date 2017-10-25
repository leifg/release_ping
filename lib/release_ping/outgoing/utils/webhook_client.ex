defmodule ReleasePing.Outgoing.Utils.WebhookClient do
  use Tesla
  plug Tesla.Middleware.Tuples

  def notify(url, message, signature, notify_event) do
    headers = %{
      "x-rp-webhook-uuid" => notify_event.uuid,
      "x-rp-webhook-subscription-id" => notify_event.subscription_uuid,
      "x-rp-webhook-session-id" => notify_event.session_uuid,
      "x-rp-webhook-attempt" => notify_event.attempt,
      "x-rp-webhook-signature" => signature
    }
    post(url, message, headers: headers)
  end
end
