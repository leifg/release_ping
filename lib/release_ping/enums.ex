defmodule ReleasePing.Enums do
  import EctoEnum
  defenum ReleaseRetrievalEnum, :release_retrieval, [:github_release_poller]
  defenum SoftwareTypeEnum, :software_type, [:application, :language, :library]
end
