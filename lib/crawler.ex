defmodule Spidey.Crawler do
  require Logger

  def crawl(start_url) do
    Stream.resource(
      fn -> {[start_url], []} end,
      fn
        {[], _found_urls} ->
          {:halt, []}
        {urls, found_urls} ->
          new_urls = urls
          |> scrape()
          |> List.flatten()
          |> Enum.uniq()
          |> Enum.reject(&Enum.member?(found_urls, &1))

          {new_urls, {new_urls, found_urls ++ new_urls}}
        end,
      fn _ -> IO.puts "Finished streaming for #{start_url}" end
    )
  end

  def scrape(urls) when is_list(urls) do
    urls
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.flat_map(&scrape/1)
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn new_urls, acc ->
      [new_urls | acc]
    end)
    |> Enum.to_list()
  end

  def scrape(url) when is_binary(url) do
    Logger.info "#{inspect(self())}\tScraping url: #{url}"
    with {:http, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} <- {:http, HTTPoison.get(url)},
         {:parse, {:ok, parsed_document}} <- {:parse, Floki.parse_document(body)} do
          parsed_document
          |> Floki.find("a")
          |> Floki.attribute("href")
          |> Enum.map(&URI.merge(url, &1))
          |> Enum.reject(&diff_host?(URI.parse(url), &1)) # limiting crawl to our host only
          |> Enum.map(&to_string/1)
    else
      {:http, {:ok, %HTTPoison.Response{status_code: 404}}} ->
        Logger.warning("Failed to get #{url}, because: not found")
        []
      {:http, {:error, %HTTPoison.Error{reason: reason}}} ->
        Logger.warning("Failed to get #{url}, because: #{reason}")
        []
      {:parse, {:error, error}} ->
        Logger.warning("Failed to parse #{url}, because: #{error}")
        []
    end
  end

  defp diff_host?(%URI{host: first_host}, %URI{host: second_host}),
    do: first_host != second_host
end
