defmodule ReleasePing.Core.Commands.AddSoftware do
  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          type: ReleasePing.Enums.software_type(),
          slug: String.t(),
          version_scheme: String.t(),
          release_notes_url_template: String.t(),
          display_version_template: String.t(),
          website: String.t(),
          github: String.t(),
          licenses: [String.t()],
          release_retrieval: ReleasePing.Enums.release_retrieval()
        }

  defstruct uuid: nil,
            name: nil,
            type: nil,
            slug: nil,
            version_scheme: nil,
            release_notes_url_template: nil,
            display_version_template: nil,
            website: nil,
            github: nil,
            licenses: [],
            release_retrieval: nil

  defimpl ReleasePing.Validation.Middleware.Uniqueness.UniqueFields,
    for: ReleasePing.Core.Commands.AddSoftware do
    def unique(%ReleasePing.Core.Commands.AddSoftware{uuid: uuid}),
      do: [
        {:github, "has already been taken", uuid}
      ]
  end
end
