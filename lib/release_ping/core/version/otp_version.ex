defmodule ReleasePing.Core.Version.OtpVersion do
  alias ReleasePing.Core.Version.SemanticVersion
  @behaviour SemanticVersion

  def parse(version) do
    pure_version = version |> String.replace(~r/^OTP[-_]/, "") |> String.replace(~r/-\w+$/, "")
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
end
