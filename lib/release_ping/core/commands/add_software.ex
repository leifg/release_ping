defmodule ReleasePing.Core.Commands.AddSoftware do
  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    type: ReleasePing.Enums.software_type,
    version_scheme: Regex.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: ReleasePing.Enums.release_retrieval,
  }

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
