defmodule ReleasePing.Core.Version.OtpVersion do
  alias ReleasePing.Core.Version.SemanticVersion
  @behaviour SemanticVersion

  def parse(version) do
    pure_version = version |> plain_version() |> String.replace(~r/-\w+$/, "")
    {major_version, minor_version, patch_version} = case String.split(pure_version, ".") do
      [major] -> {String.to_integer(major), 0, 0}
      [major, minor] -> {String.to_integer(major), String.to_integer(minor), 0}
      [major, minor, patch | _] -> {String.to_integer(major), String.to_integer(minor), String.to_integer(patch)}
    end

    %SemanticVersion{
      major: major_version,
      minor: minor_version,
      patch: patch_version,
    }
  end

  def name(version) do
    parsed_version = parse(version)
    prefix = "#{parsed_version.major}.#{parsed_version.minor}.#{parsed_version.patch}"
    plain_version = plain_version(version)
    case plain_version |> extract_pre_release() do
      nil -> plain_version
      [_all, pre_release, counter] -> "#{prefix}-#{pre_release}.#{counter}"
    end
  end

  defp plain_version(version) do
    version |> String.replace(~r/^OTP[-_]/, "")
  end

  defp extract_pre_release(version) do
    Regex.run(~r/(alpha|beta|rc)(\d+)/, version)
  end
end
