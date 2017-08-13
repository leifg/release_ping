defmodule ReleasePing.Core.Events.SoftwareAdded do
  @derive [Poison.Encoder]
  defstruct [
    uuid: nil,
    name: nil,
    website: nil,
    licenses: [],
  ]
end
