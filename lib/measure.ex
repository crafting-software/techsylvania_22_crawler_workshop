defmodule Spidey.Measure do

  def measure(func) when is_function(func) do
    {microseconds, result} = :timer.tc(func)

    IO.puts IO.ANSI.blue() <> "Finished in: #{microseconds / 1000000} seconds"

    result
  end

end
