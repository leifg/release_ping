defmodule ReleasePing.Core.Aggregates.Release do
  @moduledoc """
  Router to dispatch commands to the right aggregate
  """

  alias ReleasePing.Core.Aggregates.Release
  alias ReleasePing.Core.Commands.PublishRelease
  alias ReleasePing.Core.Events.ReleasePublished

  @type version :: %{
    major: non_neg_integer,
    minor: non_neg_integer,
    patch: non_neg_integer,
  }

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version: version,
    release_notes_url: String.t,
    published_at: DateTime.t,
    pre_release: boolean,
  }


  defstruct [:uuid, :software_uuid, :name, :version, :release_notes_url, :published_at, :pre_release]

  @doc """
  Creates software
  """
  def execute(%Release{uuid: nil}, %PublishRelease{} = publish) do
    %ReleasePublished{
      uuid: publish.uuid,
      software_uuid: publish.software_uuid,
      version: publish.version,
      release_notes_url: publish.release_notes_url,
      published_at: publish.published_at,
      pre_release: publish.pre_release,
    }
  end

  # state mutators

  def apply(%Release{} = release, %ReleasePublished{} = published) do
    %Release{release |
      uuid: published.uuid,
      software_uuid: published.software_uuid,
      version: published.version,
      release_notes_url: published.release_notes_url,
      published_at: published.published_at,
      pre_release: published.pre_release,
    }
  end
end
