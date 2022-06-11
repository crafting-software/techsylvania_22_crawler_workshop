defmodule Spidey.BookWorm do
  require Logger

  def scrape() do
    page_urls()
    |> scrape_pages()
    |> Enum.map(&scrape_book/1)
  end

  def scrape_pages(page_urls) when is_list(page_urls) do
    page_urls
    |> Enum.map(&scrape_page/1)
    |> Enum.concat()
    |> Enum.map(&URI.merge("https://books.toscrape.com/catalogue/category/books_1/", &1))
    |> tap(fn urls -> Logger.info "\n\nTotal book urls: #{length(urls)}\n\n" end)
  end

  def scrape_page(page_url) when is_binary(page_url) do
    with {:http, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} <- {:http, HTTPoison.get(page_url)},
         {:parse, {:ok, parsed_document}} <- {:parse, Floki.parse_document(body)} do
          parsed_document
          |> Floki.find("h3 a")
          |> Floki.attribute("href")
          |> tap(fn urls -> Logger.info "Found #{length(urls)} books on page #{page_url}" end)
    else
      {:http, {:ok, %HTTPoison.Response{status_code: 404}}} ->
        Logger.warning("Failed to get #{page_url}, because: not found")
        []
      {:http, {:error, %HTTPoison.Error{reason: reason}}} ->
        Logger.warning("Failed to get #{page_url}, because: #{reason}")
        []
      {:parse, {:error, error}} ->
        Logger.warning("Failed to parse #{page_url}, because: #{error}")
        []
    end
  end

  defp scrape_book(book_url) do
    with {:http, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} <- {:http, HTTPoison.get(book_url)},
         {:parse, {:ok, parsed_document}} <- {:parse, Floki.parse_document(body)} do
          parsed_document
          |> Floki.find("table tr:first-child td")
          |> Floki.text()
    else
      {:http, {:error, %HTTPoison.Error{reason: reason}}} ->
        Logger.warning("Failed to get #{book_url}, because: #{reason}")
        :empty
      {:parse, {:error, error}} ->
        Logger.warning("Failed to parse #{book_url}, because: #{error}")
        :empty
    end
  end

  defp page_urls(pages \\ 1) do
    for page_number <- 1..pages, do:
      "https://books.toscrape.com/catalogue/category/books_1/page-#{page_number}.html"
  end
end
