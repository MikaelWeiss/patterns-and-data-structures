# AGENTS.md
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an educational Elixir project for learning patterns and data structures. It does NOT use Mix - all code is plain Elixir scripts run directly with `elixir`.

## Project Structure

Each assignment/topic has its own folder containing:
- `CompetentSee.md` - Documentation file
- `Dipper.md` - Documentation file
- `.ex` file - Runnable Elixir script

Topics are organized sequentially by complexity:
1. **Variables, Tuples, Lists, List BIFs** - Basic data structures
2. **Stateless Functions** - Pure functional programming with recursion and pattern matching
3. **Stateful Functions** - Process-based state management using `spawn`, `send`, and `receive`
4. **Processes** - Manual process management patterns
5. **Supervisors** - Fault-tolerant supervision trees
6. **GenServer** - OTP GenServer implementation

## Running Code

Since this is not a Mix project, run files directly:

```bash
elixir path/to/file.ex
```

Examples:
```bash
elixir intro.ex
elixir "Stateless Functions/stateless-functions.ex"
elixir "Stateful Functions/stateful-functions.ex"
elixir Processes/processes.ex
elixir Supervisors/supervisors.ex
elixir GenServer/gen_server.ex
```

<!-- usage-rules-start -->
<!-- phoenix:elixir-start -->
## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## User Interactions

This is an educational project. The user learns best through **scaffolding with worked examples**.

**Teaching Approach:**
- DO show relevant examples from docs or existing code in this repo
- DO simplify/adapt examples to the user's specific situation
- DO explain structure, patterns, and syntax clearly
- DO keep answers short and direct
- DO ask clarifying questions that help move forward (not quiz-like)
- DO leverage that the user is good at pattern matching

**What NOT to do:**
- DO NOT write complete implementations or use Edit/Write tools unless explicitly requested
- DO NOT be vague or play "guess what's in my head"
- DO NOT leave the user struggling without enough guidance
- DO NOT provide just the answer without showing the pattern
- DO NOT write long explanations

**Example Response Pattern:**
```elixir
# Show relevant code example
def example_function(arg) do
  pattern_here
end
```
Explain the pattern: "Key concept is X, which does Y"
- Point 1 about structure
- Point 2 about syntax

"Now apply this pattern to your specific case."

# Elixir LLM Reference

Critical patterns and corrections for common LLM mistakes in Elixir.

## 1. Pattern Matching Fundamentals

### Match Operator (=) is NOT Assignment
```elixir
# WRONG thinking: x = 1 is assignment
# RIGHT: x = 1 is pattern matching that binds x to 1
x = 1          # Binds x to 1
1 = x          # Matches, returns 1
2 = x          # MatchError - no match of right hand side value: 1

# Variables can be rebound
x = 2          # x is now 2
```

### Pin Operator (^) for Existing Values
```elixir
x = 1
^x = 1         # Matches
^x = 2         # MatchError - x is already 1

# In patterns
{y, ^x} = {2, 1}   # y = 2, matches
{y, ^x} = {2, 2}   # MatchError
```

### List Pattern Matching
```elixir
[head | tail] = [1, 2, 3]  # head = 1, tail = [2, 3]
[1, 2, 3] = [1, 2, 3]      # Exact match
[1 | rest] = []             # MatchError - empty list has no head
```

## 2. String vs Charlist Operations

### CRITICAL: Concatenation Operators
```elixir
# Strings (UTF-8 binaries) - use <>
"hello" <> " world"        # "hello world"

# Charlists (lists of code points) - use ++
~c"hello" ++ ~c" world"    # ~c"hello world"

# WRONG - cross operations fail:
"hello" ++ ~c" world"      # ArgumentError
~c"hello" <> " world"      # ArgumentError
```

### String vs Charlist Conversion
```elixir
to_string(~c"hello")       # "hello"
to_charlist("hello")       # ~c"hello"

# Check types
is_binary("hello")         # true
is_list(~c"hello")         # true
```

### Multi-byte Character Pattern Matching
```elixir
# WRONG - matches byte by byte
<<head>> = "über"          # head = 195 (first byte of ü)

# RIGHT - use utf8 modifier
<<head::utf8>> = "über"    # head = 252 (code point for ü)
```

## 3. Anonymous Functions

### Definition and Calling
```elixir
# Definition
add = fn a, b -> a + b end

# CRITICAL: Use dot (.) for calling
add.(1, 2)                 # 3

# WRONG: add(1, 2) - named function call syntax
```

### Capture Operator (&)
```elixir
# Capture named function
is_atom_fun = &is_atom/1
is_atom_fun.(:hello)       # true

# Shorthand with &1, &2...
double = &(&1 * 2)
double.(5)                 # 10

# Equivalent to:
double = fn x -> x * 2 end
```

## 4. Module System

### Lexical Scope Directives
```elixir
defmodule MyModule do
  # alias - local only in this module
  alias String, as: Str

  # require - needed for macros
  require Integer

  # import - brings functions in (use sparingly)
  import List, only: [first: 1]

  def my_func do
    Str.length("hello")    # Using alias
    Integer.is_odd(3)       # Required macro
    first([1, 2, 3])       # Imported function
  end
end
```

### use vs import vs alias
```elixir
# use - invokes __using__ macro, injects code
use GenServer

# import - brings functions into current scope
import String

# alias - creates local name
alias MyApp.{User, Post}
```

## 5. Boolean Operators

### Strict (require booleans)
```elixir
true and true               # true
false or true               # true
not true                    # false

# 1 and true               # BadBooleanError
```

### Truthy (work with any value)
```elixir
1 && true                   # 1 (returns first truthy)
nil && 13                   # nil (returns first falsy)
false || 1                  # 1 (returns first truthy)
!nil                        # true
!1                          # false (only nil and false are falsy)
```

## 6. Enum vs Stream

### Enum (Eager)
```elixir
# All operations execute immediately
[1, 2, 3]
|> Enum.map(&(&1 * 2))      # [2, 4, 6]
|> Enum.filter(&(&1 > 2))   # [4, 6]
```

### Stream (Lazy)
```elixir
# Operations build up, execute when needed
[1, 2, 3]
|> Stream.map(&(&1 * 2))     # Stream operation
|> Stream.filter(&(&1 > 2))  # Stream operation
|> Enum.to_list()            # Now executes: [4, 6]
```

## 7. Pipe Operator (|>)

### Basic Usage
```elixir
# value |> function() is equivalent to function(value)
"hello" |> String.upcase()  # "HELLO"
# Same as: String.upcase("hello")

# Chaining
[1, 2, 3]
|> Enum.map(&(&1 * 2))
|> Enum.sum()               # 12
```

### Precedence Rules
```elixir
# Functions with multiple arguments
[1, 2, 3] |> Enum.take(2)   # OK: Enum.take([1, 2, 3], 2)

# For complex expressions, use parentheses
"hello" |> String.replace("l", "L") |> String.upcase()
```

## 8. Common Guard Patterns

### Available Guard Functions
```elixir
def func(x) when is_integer(x), do: :int
def func(x) when is_binary(x), do: :binary
def func(x) when x > 0, do: :positive

# Custom guards
defguard is_even(term) when is_integer(term) and rem(term, 2) == 0
def func(x) when is_even(x), do: :even
```

### Guard Limitations
```elixir
# WRONG: Can't use regular functions in guards
def func(x) when String.length(x) > 2, do: :too_long

# RIGHT: Use built-in guard functions
def func(x) when is_binary(x) and byte_size(x) > 2, do: :too_long
```

## 9. Maps and Structs

### Map Pattern Matching
```elixir
# Subset matching - pattern keys must exist
%{name: name} = %{name: "John", age: 30}  # name = "John"
%{name: name, age: age} = %{name: "John"} # MatchError - age missing

# Variable keys
key = :name
%{^key => value} = %{name: "John"}        # value = "John"
```

### Struct Patterns
```elixir
defmodule User do
  defstruct [:name, :age]
end

# Must use struct name, field validation
%User{name: name} = %User{name: "John", age: 30}
```

## 10. Common Syntax Mistakes

### Atoms
```elixir
:atom                       # Correct atom
"string"                    # String, not atom

# Booleans and nil are atoms
true == :true               # true
false == :false             # true
nil == :nil                 # true
```

### Function Arity
```elixir
# Functions identified by name/arity
String.length/1             # Function with 1 argument
String.replace/3            # Function with 3 arguments

# Different arities are different functions
String.length("hello")      # OK
String.length("hello", :utf8)  # UndefinedFunctionError
```

### List Operations
```elixir
# Prepend to list
[1 | [2, 3]]                # [1, 2, 3]
[1, 2] ++ [3, 4]            # [1, 2, 3, 4]

# WRONG: Can't prepend with ++
[1] ++ [2, 3]               # [1, 2, 3] (works, but not prepend)
```

## Quick Reference Checklist

- [ ] Using `<>` for strings, `++` for lists/charlists
- [ ] Using dot (`.`) for anonymous function calls
- [ ] Understanding `=` is pattern matching, not assignment
- [ ] Using `^` to match against existing variable values
- [ ] Using `and/or/`not` for booleans, `&&/||/!` for truthy values
- [ ] Using `alias` over `import` in application code
- [ ] Using `::utf8` for multibyte character patterns
- [ ] Understanding guards have limited function availability
- [ ] Maps do subset matching, structs require exact field names
- [ ] Streams are lazy, Enum is eager

