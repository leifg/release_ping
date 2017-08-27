defmodule ReleasePing.Github.ApiV4 do
  @default_page_size 100

  def releases(base_url, api_key, repo_owner, repo_name, last_cursor) do
    body = Poison.encode!(
      %{query: release_query(repo_owner, repo_name, @default_page_size, last_cursor)},
      iodata: true,
    )

    Tesla.post("#{base_url}/graphql", body, headers: headers(api_key))
  end

  def headers(api_key) do
    %{
      "authorization" => "bearer #{api_key}",
      "user-agent" => "Release Ping",
      "content-type" => "application/json",
    }
  end

  defp release_query(repo_owner, repo_name, page_size, last_cursor) do
    """
    query {
      rateLimit {
        cost
        limit
        nodeCount
        remaining
        resetAt
      }
      repository(owner: "#{repo_owner}", name: "#{repo_name}") {
        releases(first: #{page_size}, after: #{cursor(last_cursor)}) {
          edges {
            node {
              isDraft
              id
              name
              tag {
                name
              }
            }
            cursor
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
