defmodule Crawler do
  require Logger

  def crawl(start_url, scraper_fun) do
    Logger.info "Started streaming for '#{start_url}'..."
    Stream.resource(
      fn -> {[start_url], []} end,
      fn
        {[], _found_urls} ->
          {:halt, []}
        {urls, found_urls} ->
          {new_urls, data} = scrape(urls, scraper_fun)

          new_urls = new_urls
          |> List.flatten()
          |> Enum.uniq()
          |> Enum.reject(&diff_host?(URI.parse(start_url), &1)) # limiting crawl to our host only
          |> Enum.map(&to_string/1)
          |> Enum.reject(&Enum.member?(found_urls, &1))

          {data, {new_urls, found_urls ++ new_urls}}
        end,
      fn _ -> Logger.info "Finished streaming for '#{start_url}'." end
    )
  end

  defp scrape(urls, scraper_fun) when is_list(urls) do
    urls
    # |> Task.async_stream(&scrape(&1, scraper_fun), max_concurrency: 24)
    # |> Task.async_stream(&scrape(&1, scraper_fun), ordered: false, timeout: 10000, max_concurrency: 100)
    # |> Enum.into([], fn {_key, value} -> value end)
    |> Enum.map(&scrape(&1, scraper_fun))
    |> Enum.reduce({[],[]}, fn {scraped_urls, scraped_data}, {acc_urls, acc_data} ->
      {scraped_urls ++ acc_urls, scraped_data ++ acc_data}
    end)
    # |> IO.inspect(label: :merged)
  end

  defp scrape(url, scraper_fun) when is_binary(url) do
    Logger.info "#{inspect(self())}\tScraping url: #{url}"
    with {:http, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} <- {:http, HTTPoison.get(url)},
         {:parse, {:ok, parsed_document}} <- {:parse, Floki.parse_document(body)} do
          new_urls = parsed_document
          |> Floki.find("a")
          |> Floki.attribute("href")
          |> Enum.map(&URI.merge(url, &1))  # to absolute url

          new_data = case scraper_fun.(parsed_document) do
            x when is_list(x) -> x
            x -> [x]
          end
          {new_urls, [] ++ new_data}
    else
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
