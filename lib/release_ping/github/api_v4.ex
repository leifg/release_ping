defmodule ReleasePing.Github.ApiV4 do
  @spec releases(String.t(), String.t(), ReleaseRequest.t()) :: Tesla.Env.t()
  def releases(base_url, api_key, release_request) do
    body = Poison.encode!(%{query: releases_query(release_request)}, iodata: true)

    Tesla.post("#{base_url}/graphql", body, headers: headers(api_key))
  end

  @spec rate_limit(String.t(), String.t()) :: Tesla.Env.t()
  def rate_limit(base_url, api_key) do
    Tesla.get("#{base_url}/rate_limit", headers: headers(api_key))
  end

  def headers(api_key) do
    %{
      "authorization" => "bearer #{api_key}",
      "user-agent" => "Release Ping",
      "content-type" => "application/json"
    }
  end

  defp releases_query(release_request) do
    """
    query {
      rateLimit {
        cost
        limit
        nodeCount
        remaining
        resetAt
      }
      repository(owner: "#{release_request.repo_owner}", name: "#{release_request.repo_name}") {
        tags: refs(refPrefix: "refs/tags/", first: #{release_request.page_size}, after: #{
      cursor(release_request.last_cursor_tags)
    }, orderBy: {field: TAG_COMMIT_DATE, direction:ASC}) {
          edges {
            cursor
            node {
              id
              name
              target {
                ... on Tag {
                  id
                  message
                  author:tagger {
                    name
                    date
                  }
                }
                ... on Commit {
                  id
                  message
                  author:committer {
                    name
                    date
                  }
                }
              }
            }
          }
          pageInfo {
           endCursor
           hasNextPage
           hasPreviousPage
           startCursor
          }
        }
        releases(first: #{release_request.page_size}, after: #{
      cursor(release_request.last_cursor_releases)
    }) {
          edges {
            cursor
            node {
              id
              name
              description
              publishedAt
              isDraft
              isPrerelease
              url
              tag {
                id
                name
              }
            }
          }
          pageInfo {
           endCursor
           hasNextPage
           hasPreviousPage
           startCursor
          }
        }
      }
    }
    """
  end

  defp cursor(nil) do
    "null"
  end

  defp cursor(cursor) do
    inspect(cursor)
  end
end
