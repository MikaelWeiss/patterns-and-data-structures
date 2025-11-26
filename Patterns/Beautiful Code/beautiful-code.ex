defmodule BeautifulCode do
  def start do
    IO.puts("=== Hi there! Welcome to my CLI ===")

    IO.puts("""
      Commands:
      q - quits
      a - add two numbers
      m - multiply two numbers
      g - greet the user
    """)

    loop()
  end

  defp loop do
    command = IO.gets("> ") |> String.trim()
    process_command(command)
  end

  defp process_command(c) when c == "q" do
    IO.puts("Goodbye 🥹")
  end

  defp process_command(c) when c == "exit" do
    IO.puts("Goodbye 🥹 (but hidden)")
  end

  defp process_command(c) when c == "a" do
    num1 =
      IO.gets("Number 1 > ")
      |> String.trim()
      |> parse

    num2 =
      IO.gets("Number 2 > ")
      |> String.trim()
      |> parse

    IO.puts("#{num1} + #{num2} = #{num1 + num2}")
    loop()
  end

  defp process_command(c) when c == "m" do
    num1 =
      IO.gets("Number 1 > ")
      |> String.trim()
      |> parse

    num2 =
      IO.gets("Number 2 > ")
      |> String.trim()
      |> parse

    IO.puts("#{num1} * #{num2} = #{num1 * num2}")
    loop()
  end

  defp process_command(c) when c == "g" do
    name =
      IO.gets("Hey there! What's " <> italicize("your") <> " name? \n> ")
      |> String.trim()

    IO.puts("Hi there, #{name}!")
    IO.puts("I hope you're enjoying this CLI")
    loop()
  end

  defp process_command(_c) do
    IO.puts("This is not the command you seek")
    loop()
  end

  defp italicize(input) do
    IO.ANSI.italic() <> input <> IO.ANSI.reset()
  end

  defp parse(input) do
    case Integer.parse(input) do
      {number, ""} ->
        number

      :error ->
        IO.puts("Really? Bruh. You didn't enter a number. Defaulting to 0.")
        0
    end
  end
end

BeautifulCode.start()
