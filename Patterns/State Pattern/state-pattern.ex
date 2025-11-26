defmodule Thermy do
  def start() do
    IO.puts("""
    === Welcome to Thermy! ===
    Here are your commands:
    g - get the current thermostat temp
    s - set the thermostat temp
    q - quit
    """)

    loop(72)
  end

  defp loop(temp) do
    input = IO.gets("> ") |> String.trim()
    handle(input, temp)
  end

  defp handle(input, temp) when input == "g" do
    IO.puts("Here's the current temp: #{temp}")
    loop(temp)
  end

  defp handle(input, _temp) when input == "s" do
    new_temp =
      IO.gets("New temp: ")
      |> String.trim()
      |> parse

    loop(new_temp)
  end

  defp handle(input, _temp) when input == "q" do
    IO.puts("Goodbye 🥹")
  end

  defp handle(_input, temp) do
    IO.puts("That's not a valid input..... Silly goose. Try again.")
    loop(temp)
  end

  defp parse(input) do
    case Integer.parse(input) do
      {number, ""} ->
        number

      :error ->
        IO.puts("Really? Bruh. You didn't enter a number. Defaulting to 72.")
        72
    end
  end
end

Thermy.start()
