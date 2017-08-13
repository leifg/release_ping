defmodule ReleasePing.Router do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  use Commanded.Commands.Router

  alias ReleasePing.Core.Aggregates.{Software, Release}
  alias ReleasePing.Core.Commands.{AddSoftware, PublishRelease}

  dispatch [AddSoftware], to: Software, identity: :uuid
  dispatch [PublishRelease], to: Release, identity: :uuid
end
