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

## 11. Processes and OTP

### GenServer Basics
```elixir
defmodule Stack do
  use GenServer

  # Client API
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server callbacks
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end
```

### Call vs Cast vs Info
```elixir
# Synchronous call - waits for reply
GenServer.call(pid, :get_state)     # Returns state

# Asynchronous cast - returns :ok immediately
GenServer.cast(pid, :do_something) # Returns :ok

# Send regular message - handled by handle_info/2
send(pid, :regular_message)
```

### Tasks for Concurrency
```elixir
# Async task that must be awaited
task = Task.async(fn -> expensive_work() end)
result = Task.await(task, 5000)    # 5 second timeout

# Fire-and-forget task
Task.start(fn -> background_work() end)

# Task supervision
Task.Supervisor.start_child(supervisor, fn -> work() end)
```

### Supervisor Child Specs
```elixir
children = [
  # Simple tuple form
  {MyApp.Worker, arg},

  # Module-based
  MyApp.Worker,

  # With options
  %{
    id: MyApp.Worker,
    start: {MyApp.Worker, :start_link, [arg]},
    restart: :permanent,  # :permanent, :transient, :temporary
    shutdown: 5000,       # milliseconds or :infinity
    type: :worker         # :worker or :supervisor
  }
]

Supervisor.start_link(children, strategy: :one_for_one)
```

## 12. Protocols and Behaviours

### Defining Protocols
```elixir
defprotocol Size do
  @doc "Calculates the size of a data structure"
  def size(data)
end

# Implement for different types
defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: List do
  def size(list), do: length(list)
end

# Usage
Size.size(%{a: 1, b: 2})  # 2
Size.size([1, 2, 3])      # 3
```

### Behaviours for Interfaces
```elixir
defmodule Parser do
  @callback parse(String.t()) :: {:ok, term} | {:error, atom}
  @callback extensions() :: [String.t()]
end

defmodule JSONParser do
  @behaviour Parser

  @impl Parser
  def parse(str), do: {:ok, "json: " <> str}

  @impl Parser
  def extensions, do: [".json"]
end
```

## 13. Error Handling Patterns

### Elixir Error Handling Philosophy
- **Expected failures**: Return tuples `{:ok, result}` | `{:error, reason}`
- **Unexpected failures**: Raise exceptions and let them crash
- **Prefer `case`** over `try/rescue` for expected outcomes

### With Statement for Clean Error Flow
```elixir
# Clean chain of operations that all must succeed
result =
  with {:ok, user} <- fetch_user(id),
       {:ok, posts} <- fetch_user_posts(user),
       {:ok, comments} <- fetch_post_comments(posts) do
    {:ok, %{user: user, posts: posts, comments: comments}}
  else
    {:error, :user_not_found} -> {:error, "User not found"}
    {:error, reason} -> {:error, "Failed: #{reason}"}
  end
```

### Try/Rescue (Rare Usage)
```elixir
# Only for external libraries or truly exceptional cases
try do
  dangerous_external_thing()
rescue
  error in RuntimeError ->
    Logger.error("Runtime error: #{error}")
    {:error, error}
catch
  :exit, reason -> {:error, "Process exited: #{reason}"}
  :throw, value -> {:error, "Unexpected throw: #{value}"}
end
```

## 14. Advanced Data Structures

### Access Behaviour for Dynamic Access
```elixir
# Safe nested access
users = %{"john" => %{age: 27}}
get_in(users, ["john", :age])           # 27
get_in(users, ["unknown", :age])        # nil

# Update nested structures
put_in(users["john"].age, 28)           # %{"john" => %{age: 28}}

# Access.all() for list operations
list = [%{name: "john"}, %{name: "meg"}]
get_in(list, [Access.all(), :name])     # ["john", "meg"]
```

### Structs vs Maps
```elixir
defmodule User do
  defstruct [:name, :age]

  @enforce_keys [:name]  # Compile-time requirement
end

# Structs have strict key access
user = %User{name: "John", age: 27}
user.name                    # "John"
user[:name]                  # ** (KeyError) - no bracket access for structs

# Maps allow bracket access
map = %{name: "John", age: 27}
map.name                     # "John" (atom keys only)
map[:name]                   # "John"
map["name"]                  # nil (different key type)
```

## 15. Comprehensions and Sigils

### List Comprehensions
```elixir
# Basic comprehensions
for n <- [1, 2, 3, 4], do: n * n
# [1, 4, 9, 16]

# With filters
for n <- 1..10, rem(n, 2) == 0, do: n
# [2, 4, 6, 8, 10]

# Multiple generators (Cartesian product)
for i <- [:a, :b], j <- [1, 2], do: {i, j}
# [a: 1, a: 2, b: 1, b: 2]

# Pattern matching in generators
values = [good: 1, good: 2, bad: 3]
for {:good, n} <- values, do: n * n
# [1, 4]

# Custom collectable
for <<c <- " hello ">>, c != ?\s, into: "", do: <<c>>
# "hello"
```

### Common Sigils
```elixir
# Regular expressions
~r/hello/i                 # Case-insensitive regex
"HELLO" =~ ~r/hello/i       # true

# Strings with custom delimiters (avoid escaping)
~s(this has "quotes" inside)

# Word lists
~w(apple banana cherry)    # ["apple", "banana", "cherry"]
~w(apple banana cherry)a   # [:apple, :banana, :cherry]

# Charlists
~c"hello"                  # [104, 101, 108, 108, 111]

# Dates and times
~D[2023-12-25]             # %Date{}
~T[14:30:00]               # %Time{}
~U[2023-12-25 14:30:00Z]   # %DateTime{} in UTC
```

## 16. Module Attributes and Documentation

### Module Attributes
```elixir
defmodule MyModule do
  @moduledoc "This module does X, Y, and Z"
  @version "1.0.0"

  @doc "Does something important"
  @spec my_function(integer()) :: String.t()
  def my_function(x) when is_integer(x) do
    Integer.to_string(x)
  end

  @doc false  # Don't include in docs
  defp helper_function, do: :ok
end
```

### Application Configuration
```elixir
# config/config.exs
import Config

config :my_app,
  api_key: System.get_env("API_KEY"),
  port: 4000,
  some_setting: true

# Environment-specific
import_config "#{config_env()}.exs"
```

## 17. Ranges and Enumerables

### Range Operations
```elixir
# Inclusive ranges
1..5        # [1, 2, 3, 4, 5]
1..5//2     # [1, 3, 5] (step of 2)

# Exclusive ranges
1...5       # [1, 2, 3, 4] (5 excluded)

# Range functions
Range.range(1, 10)          # 1..10
Range.range(1, 10, 2)      # 1, 3, 5, 7, 9
```

### Agent for Simple State
```elixir
# Simple state management (lighter than GenServer)
{:ok, agent} = Agent.start_link(fn -> 0 end)

# Get state
Agent.get(agent, &(&1))     # 0

# Update state
Agent.update(agent, &(&1 + 1))  # :ok
Agent.get(agent, &(&1))          # 1

# Get and update in one operation
Agent.get_and_update(agent, fn state ->
  {state, state + 1}
end)  # {1, 2}
```

### Registry for Process Discovery
```elixir
# Start registry
{:ok, registry} = Registry.start_link(keys: :unique, name: MyRegistry)

# Register a process
Registry.register(MyRegistry, :my_key, :metadata)

# Lookup processes
Registry.lookup(MyRegistry, :my_key)  # [{pid, :metadata}]

# Send messages to registered processes
Registry.dispatch(MyRegistry, :my_key, fn {pid, meta} ->
  send(pid, {:message, meta})
end)
```

## 18. Common Exception Types

### Specific Error Types
```elixir
# Function doesn't exist
UndefinedFunctionError

# Function exists but wrong arity
FunctionClauseError

# Pattern match fails
MatchError
CaseClauseError
WithClauseError

# Map/key access errors
KeyError
BadMapError

# Type-related errors
BadBooleanError
BadArityError
BadFunctionError

# Protocol errors
Protocol.UndefinedError

# Struct errors
BadStructError
```

### Creating Custom Exceptions
```elixir
defmodule MyApp.BusinessError do
  defexception [:message, :code]

  @impl true
  def message(%{code: code, message: msg}) do
    "Business Error #{code}: #{msg}"
  end
end

# Usage
raise MyApp.BusinessError, code: 404, message: "Not found"
```

## 19. Typespecs for Documentation

### Basic Type Specifications
```elixir
defmodule Calculator do
  @typedoc "A numeric result"
  @type result() :: {:ok, number()} | {:error, String.t()}

  @spec add(number(), number()) :: result()
  def add(a, b) do
    {:ok, a + b}
  end

  @spec divide(number(), number()) :: result()
  def divide(_, 0), do: {:error, "Division by zero"}
  def divide(a, b), do: {:ok, a / b}
end
```

### Common Built-in Types
```elixir
# Use these, not Erlang types
String.t()                  # Same as binary() for strings
keyword()                   # [{atom(), any()}]
timeout()                   # :infinity | non_neg_integer()
```

## Quick Reference Checklist

### Syntax and Patterns
- [ ] Using `<>` for strings, `++` for lists/charlists
- [ ] Using dot (`.`) for anonymous function calls
- [ ] Understanding `=` is pattern matching, not assignment
- [ ] Using `^` to match against existing variable values
- [ ] Using `and/or/not` for booleans, `&&/||/!` for truthy values

### Module and Function System
- [ ] Using `alias` over `import` in application code
- [ ] Understanding function arity (name/arity uniquely identifies functions)
- [ ] Using `::utf8` for multibyte character patterns
- [ ] Understanding guards have limited function availability

### Data Structures
- [ ] Maps do subset matching, structs require exact field names
- [ ] Streams are lazy, Enum is eager
- [ ] Structs don't support bracket access `[key]`
- [ ] Keyword lists are for options, maps for structured data

### OTP and Concurrency
- [ ] GenServer: call for sync, cast for async, info for messages
- [ ] Tasks: async/await for results, start for fire-and-forget
- [ ] Supervisors: one_for_one strategy, proper child specs
- [ ] Let it crash for unexpected errors, return tuples for expected failures

### Error Handling and Control Flow
- [ ] Use `with` for chained operations that may fail
- [ ] Prefer `case` over `try/rescue` for expected failures
- [ ] Only rescue truly exceptional cases
- [ ] Use `else` clause in `with` for successful result processing

### Module and Application Structure
- [ ] Use `@moduledoc` and `@doc` for module/function documentation
- [ ] Configure applications in `config/config.exs` with `import Config`
- [ ] Use Agent for simple state (lighter than GenServer)
- [ ] Use Registry for process discovery and registration
- [ ] Create custom exceptions with `defexception`

### Common LLM Pitfalls to Avoid
- [ ] **Never mix `<>` and `++`** - strings use `<>`, charlists use `++`
- [ ] **Always use dot `.`** for anonymous function calls: `fun.(args)`
- [ ] **Use `^` pin operator** when matching against existing variables
- [ ] **Structs don't support bracket access** - use `struct.field` not `struct[:field]`
- [ ] **Guards are limited** - only built-in functions like `is_*`, `byte_size`, etc.
- [ ] **Maps do subset matching** - only pattern keys need to exist
- [ ] **Function arity matters** - `fun/1` and `fun/2` are different functions
- [ ] **Use strict boolean operators** (`and/or/not`) in guards, truthy (`&&/||/!`) elsewhere
