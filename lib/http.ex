defmodule Spidey.Http do

  require Logger

  def get_body(url) do
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "REQUEST FAILED : #{reason}"
        {:error, reason: reason}
    end
  end

end
