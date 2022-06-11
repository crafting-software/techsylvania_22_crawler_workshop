defmodule Spidey.UrlUtils do

  def to_absolute_url(urls, base_url) when is_list(urls), do:
    urls
    |> Enum.map(fn url -> to_absolute_url(url, base_url) end)

  def to_absolute_url("../.." <> remaining, base_url), do: base_url <> remaining
  def to_absolute_url(url, base_url) when is_binary(url) do
    case String.starts_with?(url, base_url) do
      true -> url
      _ -> base_url <> url
    end
  end

  def to_absolute(source_url, "../" <> relative_url), do: to_absolute(source_url, 1, relative_url)
  def to_absolute(source_url, "../../" <> relative_url), do: to_absolute(source_url, 2, relative_url)
  def to_absolute(source_url, "../../../" <> relative_url), do: to_absolute(source_url, 3, relative_url)
  def to_absolute(source_url, "../../../../" <> relative_url), do: to_absolute(source_url, 4, relative_url)
  def to_absolute(_source_url, relative_url), do: relative_url

  def to_absolute(source_url, pop_count, relative_url) do
    popped = source_url
      |> String.trim("/")
      |> String.split("/")
      |> Enum.reverse()
      |> Enum.drop(pop_count + 1)
      |> Enum.reverse()
      |> Enum.join("/")

    popped <> "/" <> relative_url
  end



end
