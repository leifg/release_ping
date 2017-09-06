defmodule ReleasePing.Core.Commands.AddSoftware do
  defstruct [
    uuid: nil,
    name: nil,
    type: nil,
    website: nil,
    github: nil,
    licenses: [],
    release_retrieval: nil,
  ]
end
