# Variables
hi_there = "Hi there"

# Tuples
person = {"Utah", "USA"}
IO.inspect(person)

# Lists
name_split = ["M", "I", "K", "A", "E", "L"]
IO.inspect(name_split)

name = List.to_string(name_split)
IO.puts(name)

# List BIFs
nums = [1, 2, 3, 4, 4, 5, 6]
IO.inspect(nums)

uniqNums = Enum.uniq(nums)
IO.inspect(uniqNums)
