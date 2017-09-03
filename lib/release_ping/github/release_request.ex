defmodule ReleasePing.Github.ReleaseRequest do
  @default_page_size 100

  @type t :: %__MODULE__{
    repo_owner: String.t,
    repo_name: String.t,
    page_size: pos_integer,
    last_cursor_releases: String.t,
    last_cursor_tags: String.t
  }

  defstruct [
    repo_owner: nil,
    repo_name: nil,
    page_size: @default_page_size,
    last_cursor_releases: nil,
    last_cursor_tags: nil
  ]
end
