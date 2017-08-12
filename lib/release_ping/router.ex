defmodule ReleasePing.Router do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  use Commanded.Commands.Router

  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.AddSoftware

  dispatch [AddSoftware], to: Software, identity: :uuid
end
