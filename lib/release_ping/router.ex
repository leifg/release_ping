defmodule ReleasePing.Router do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  use Commanded.Commands.Router

  alias ReleasePing.Core.Aggregates.Software

  alias ReleasePing.Core.Commands.{
    AddSoftware,
    AdjustReleaseNotesUrl,
    ChangeLicenses,
    ChangeVersionScheme,
    CorrectName,
    CorrectReleaseNotesUrlTemplate,
    CorrectSlug,
    CorrectSoftwareType,
    CorrectWebsite,
    PublishRelease
  }

  alias ReleasePing.Incoming.Aggregates.GithubEndpoint

  alias ReleasePing.Incoming.Commands.{
    AdjustCursor,
    ConfigureGithubEndpoint,
    ChangeGithubToken,
    PollGithubReleases
  }

  alias ReleasePing.Outgoing.Aggregates.Subscription
  alias ReleasePing.Outgoing.Commands.{AddTrustedSubscription, NotifySubscriber}

  middleware(ReleasePing.Validation.Middleware.Uniqueness)

  dispatch([AddSoftware], to: Software, identity: :uuid)

  dispatch(
    [
      AdjustReleaseNotesUrl,
      ChangeLicenses,
      ChangeVersionScheme,
      CorrectName,
      CorrectReleaseNotesUrlTemplate,
      CorrectSlug,
      CorrectSoftwareType,
      CorrectWebsite,
      PublishRelease
    ],
    to: Software,
    identity: :software_uuid
  )

  dispatch([ConfigureGithubEndpoint], to: GithubEndpoint, identity: :uuid)

  dispatch(
    [AdjustCursor, PollGithubReleases, ChangeGithubToken],
    to: GithubEndpoint,
    identity: :github_uuid
  )

  dispatch([AddTrustedSubscription], to: Subscription, identity: :uuid)
  dispatch([NotifySubscriber], to: Subscription, identity: :subscription_uuid)
end
