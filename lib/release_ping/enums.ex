defmodule ReleasePing.Enums do
  import EctoEnum
  defenum ReleaseRetrievalEnum, :release_retrieval, [:github_release_poller]
end
