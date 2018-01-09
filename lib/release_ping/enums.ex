defmodule ReleasePing.Enums do
  import EctoEnum

  @type release_retrieval :: :github_release_poller
  @type software_type :: :application | :language | :library

  defenum(ReleaseRetrievalEnum, :release_retrieval, [:github_release_poller])
  defenum(SoftwareTypeEnum, :software_type, [:application, :language, :library])
end
