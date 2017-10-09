defmodule ReleasePing.Core.Commands.AddSoftware do
  defstruct [
    uuid: nil,
    name: nil,
    type: nil,
    version_scheme: nil,
    website: nil,
    github: nil,
    licenses: [],
    release_retrieval: nil,
  ]

  defimpl ReleasePing.Validation.Middleware.Uniqueness.UniqueFields, for: ReleasePing.Core.Commands.AddSoftware do
    def unique(%ReleasePing.Core.Commands.AddSoftware{uuid: uuid}), do: [
      {:github, "has already been taken", uuid},
    ]
  end
end
