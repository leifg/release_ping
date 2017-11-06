defmodule ReleasePing.Api.VersionUtils do
  alias ReleasePing.Api.Software.Version

  @type compare_result :: :lt | :gt | :eq

  @spec compare(Version.t, Version.t) :: compare_result
  def compare(version1, version2) do
    {:ok, cmp1} = dump(version1)
    {:ok, cmp2} = dump(version2)

    cond do
      cmp1 > cmp2 -> :gt
      cmp1 < cmp2 -> :lt
      cmp1 == cmp2 -> :eq
    end
  end

  defp dump(%Version{major: major, minor: minor, patch: patch, published_at: published_at}) do
    {:ok, published_at} = dump(published_at)
    {:ok, {major, minor, patch, published_at}}
  end
  defp dump(input) when is_binary(input), do: {:ok, input}
  defp dump(%DateTime{} = datetime) do
    {:ok, DateTime.to_unix(datetime)}
  end
  defp dump(%NaiveDateTime{} = datetime) do
    datetime |> DateTime.from_naive!("Etc/UTC") |> dump()
  end
end
