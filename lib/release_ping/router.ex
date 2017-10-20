defmodule ReleasePing.Router do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  use Commanded.Commands.Router

  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.{
    AddSoftware,
    ChangeLicenses,
    ChangeVersionScheme,
    CorrectName,
    CorrectReleaseNotesUrlTemplate,
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

  middleware ReleasePing.Validation.Middleware.Uniqueness

  dispatch [AddSoftware], to: Software, identity: :uuid
  dispatch [
    ChangeLicenses,
    ChangeVersionScheme,
    CorrectName,
    CorrectReleaseNotesUrlTemplate,
    CorrectSoftwareType,
    CorrectWebsite,
    PublishRelease
  ], to: Software, identity: :software_uuid

  dispatch [ConfigureGithubEndpoint], to: GithubEndpoint, identity: :uuid
  dispatch [AdjustCursor, PollGithubReleases, ChangeGithubToken], to: GithubEndpoint, identity: :github_uuid
end
