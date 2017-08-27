defmodule ReleasePing.Router do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  use Commanded.Commands.Router

  alias ReleasePing.Core.Aggregates.{Software, Release}
  alias ReleasePing.Core.Commands.{AddSoftware, PublishRelease}

  alias ReleasePing.Incoming.Aggregates.{Github}
  alias ReleasePing.Incoming.Commands.{ConfigureGithubEndpoint, PollGithubReleases}

  dispatch [AddSoftware], to: Software, identity: :uuid
  dispatch [PublishRelease], to: Release, identity: :uuid

  dispatch [ConfigureGithubEndpoint], to: Github, identity: :uuid
  dispatch [PollGithubReleases], to: Github, identity: :github_uuid
end
