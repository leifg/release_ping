defmodule ReleasePing.Router do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  use Commanded.Commands.Router

  alias ReleasePing.Core.Aggregates.{Software, Release}
  alias ReleasePing.Core.Commands.{AddSoftware, PublishRelease}

  alias ReleasePing.Incoming.Aggregates.{GithubEndpoint}
  alias ReleasePing.Incoming.Commands.{ConfigureGithubEndpoint, ChangeGithubToken, PollGithubReleases}

  middleware ReleasePing.Validation.Middleware.Uniqueness

  dispatch [AddSoftware], to: Software, identity: :uuid
  dispatch [PublishRelease], to: Release, identity: :uuid

  dispatch [ConfigureGithubEndpoint], to: GithubEndpoint, identity: :uuid
  dispatch [PollGithubReleases, ChangeGithubToken], to: GithubEndpoint, identity: :github_uuid
end
