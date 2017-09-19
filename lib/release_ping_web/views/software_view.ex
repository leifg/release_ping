defmodule ReleasePingWeb.SoftwareView do
  use ReleasePingWeb, :view
  alias ReleasePingWeb.SoftwareView

  def render("index.json", %{software: software}) do
    render_many(software, SoftwareView, "software.json")
  end

  def render("show.json", %{software: software}) do
    render_one(software, SoftwareView, "software.json")
  end

  def render("software.json", %{software: software}) do
    %{
      id: software.id,
      name: software.name,
      website: software.website,
      licenses: software.licenses,
      latest_version_stable: version_fields(software.latest_version_stable),
      latest_version_unstable: version_fields(software.latest_version_unstable),
    }
  end

  defp version_fields(version) do
    %{
      id: version.id,
      name: version.name,
      release_notes_url: version.release_notes_url,
      published_at: version.published_at,
    }
  end
end
