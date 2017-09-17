defmodule ReleasePingWeb.SoftwareView do
  use ReleasePingWeb, :view
  alias ReleasePingWeb.SoftwareView

  def render("index.json", %{software: software}) do
    render_many(software, SoftwareView, "software.json")
  end

  def render("show.json", %{software: software}) do
    %{data: render_one(software, SoftwareView, "software.json")}
  end

  def render("software.json", %{software: software}) do
    %{
      id: software.id,
      name: software.name,
      website: software.website,
      licenses: software.licenses,
    }
  end
end
