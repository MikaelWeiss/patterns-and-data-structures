# Elixir LLM Correction Guide

**Purpose**: Minimal, high-impact corrections for common LLM errors in Elixir documentation/code generation.

---

## ⚡ CRITICAL ERRORS - TOP 20

These are the most frequent and breaking mistakes LLMs make when working with Elixir:

### 🔴 P0: Syntax Errors (Code-Breaking)

1. **❌ WRONG: `[head :: tail]`**
   **✅ CORRECT: `[head | tail]`**
   ```elixir
   # Wrong - will not compile
   [h :: t] = [1, 2, 3]

   # Correct - list cons operator
   [h | t] = [1, 2, 3]  # h = 1, t = [2, 3]
   ```

2. **❌ Map update with non-existent keys raises KeyError**
   ```elixir
   # Wrong - raises KeyError if :new_key doesn't exist
   %{map | new_key: value}

   # Correct - use Map.put/3 to add new keys
   Map.put(map, :new_key, value)
   ```

3. **❌ WRONG: `string()` type**
   **✅ CORRECT: `String.t()` or `binary()`**
   ```elixir
   # Wrong - refers to Erlang charlists
   @spec process(string()) :: string()

   # Correct - UTF-8 binary strings
   @spec process(String.t()) :: String.t()
   ```

### 🟠 P1: Non-Existent Functions (Code-Breaking)

4. **`String.titleize/1` does NOT exist** (use custom implementation)

5. **`String.empty?/1` does NOT exist**
   ```elixir
   # Wrong
   String.empty?(str)

   # Correct
   String.length(str) == 0
   # or
   str == ""
   ```

6. **Arithmetic functions are in `Kernel`, NOT `Integer`**
   ```elixir
   # Wrong
   Integer.div(10, 3)
   Integer.floor(5.7)

   # Correct
   div(10, 3)
   floor(5.7)
   ```

7. **`IO.read(device, :all)` does NOT exist**
   ```elixir
   # Wrong
   IO.read(device, :all)

   # Correct - valid options: :eof, :line, or integer count
   IO.read(device, :eof)
   ```

8. **`Task.await/1` returns VALUE directly, NOT `{:ok, value}`**
   ```elixir
   # Wrong
   {:ok, result} = Task.await(task)

   # Correct - returns unwrapped value, raises on timeout
   result = Task.await(task)
   ```

### 🟡 P2: Critical Behavioral Errors

9. **`GenServer.terminate/2` is NOT guaranteed to be called**
   ```elixir
   # Wrong - unreliable cleanup
   def terminate(_reason, state) do
     Database.close(state.conn)  # May never execute!
   end

   # Correct - use links/monitors for critical cleanup
   def init(args) do
     Process.flag(:trap_exit, true)
     # Or use proper supervision
   end
   ```

10. **`Task.await/1` can only be called ONCE per task**
    ```elixir
    # Wrong
    result1 = Task.await(task)
    result2 = Task.await(task)  # Will fail!

    # Correct - await only once
    result = Task.await(task)
    ```

11. **Protocols dispatch on FIRST argument only**
    ```elixir
    # Wrong assumption - cannot dispatch on second arg
    defprotocol Converter do
      def convert(source, target_type)
    end

    # Correct - dispatch only on 'source'
    defprotocol Converter do
      def convert(source)
    end
    ```

12. **`String.length/1` counts graphemes, NOT bytes**
    ```elixir
    String.length("🎉")     # 1 grapheme
    byte_size("🎉")         # 4 bytes
    String.length("é")      # 1 grapheme (may be 1-2 code points)
    ```

13. **`String.to_atom/1` causes atom table leaks with untrusted input**
    ```elixir
    # Wrong - vulnerable to atom table exhaustion
    def create_user(params) do
      String.to_atom(params["username"])
    end

    # Correct - use existing atoms only
    String.to_existing_atom(safe_value)
    # Or use strings/binaries instead
    ```

14. **Empty enumerables: `Enum.all?/2` → `true`, `Enum.any?/2` → `false`**
    ```elixir
    Enum.all?([], fn _ -> false end)  # true (vacuous truth)
    Enum.any?([], fn _ -> true end)   # false (no elements)
    ```

15. **`Enum.max/1` and `Enum.min/1` raise `Enum.EmptyError` on empty lists**
    ```elixir
    # Wrong - will crash
    Enum.max([])

    # Correct - use safe version with default
    Enum.max(list, fn -> 0 end)
    ```

### 🔵 P3: Wrong Return Types

16. **`ETS.new/2` returns table identifier directly, NOT `{:ok, table}`**
    ```elixir
    # Wrong
    {:ok, table} = :ets.new(:my_table, [:set])

    # Correct
    table = :ets.new(:my_table, [:set])
    ```

17. **`Task.start/1` returns `{:ok, pid}`, `Task.start_link/1` returns `{:ok, pid}`**
    ```elixir
    # Wrong
    pid = Task.start(fn -> work() end)

    # Correct
    {:ok, pid} = Task.start(fn -> work() end)
    ```

18. **`File.read/1` has NO arity 2 version**
    ```elixir
    # Wrong
    File.read(path, options)

    # Correct - only /1 exists
    File.read(path)
    ```

### 🟣 P4: Module Scope Confusion

19. **`Atom` module has ONLY `to_string/1` and `to_charlist/1`**
    ```elixir
    # LLMs often document non-existent functions like:
    # Atom.new/1, Atom.valid?/1, Atom.exists?/1 - NONE exist

    # Correct - only conversions
    Atom.to_string(:hello)
    Atom.to_charlist(:world)
    ```

20. **`Process.exit(pid, :normal)` does NOT exit the process (except caller)**
    ```elixir
    # Wrong - won't kill other processes
    Process.exit(pid, :normal)

    # Correct - use :kill for unconditional exit
    Process.exit(pid, :kill)
    # Or use other reasons
    Process.exit(pid, :shutdown)
    ```

---

## Critical Syntax Errors

### List Cons Cell Operator (⚠️ P0)
- **WRONG**: `[head :: tail]`
- **CORRECT**: `[head | tail]`
```elixir
# Pattern matching
[first | rest] = [1, 2, 3, 4]
# first = 1, rest = [2, 3, 4]

# Building lists
[0 | [1, 2, 3]]  # [0, 1, 2, 3]
```

### String Type Terminology (⚠️ P0)
- **AVOID**: `string()` type (refers to Erlang charlists)
- **USE**: `String.t()`, `binary()`, or `charlist()`
```elixir
# Wrong - misleading type
@spec reverse(string()) :: string()

# Correct - clear UTF-8 string type
@spec reverse(String.t()) :: String.t()

# Or for Erlang charlists
@spec reverse(charlist()) :: charlist()
```

### Map Update Syntax Constraint (⚠️ P0)
- `%{map | key: value}` **raises KeyError** for non-existing keys
- **Cannot add new keys** with this syntax - use `Map.put/3`
```elixir
map = %{a: 1, b: 2}

# Wrong - raises KeyError
%{map | c: 3}

# Correct - updates existing key
%{map | a: 10}  # %{a: 10, b: 2}

# Correct - adds new key
Map.put(map, :c, 3)  # %{a: 1, b: 2, c: 3}
```

### Comparison Operators (⚠️ P2)
- Maps and Keywords use `===/2` (strict equality), **NOT** `==/2` (value equality)
- Affects duplicate key detection and equality checks
```elixir
# Map keys use strict equality
%{1 => :int, 1.0 => :float}  # Two different keys!

# Value equality vs strict equality
1 == 1.0   # true (value equality)
1 === 1.0  # false (strict equality)
```

## Function Signature Errors

### Return Type Patterns (⚠️ P1)

**Task module** - Returns raw values, NOT tuples:
- `Task.await/2` → `result` (raises on timeout, not `{:error, :timeout}`)
```elixir
# Wrong
{:ok, result} = Task.await(task)

# Correct - returns unwrapped value
result = Task.await(task)
```

- `Task.start/1` → **WRONG** - actually returns `{:ok, pid()}`
- `Task.start_link/1,3` → `{:ok, pid()}`

**IO module** - Raw returns:
- Read operations → `chardata() | :eof | {:error, reason}` (not `{:ok, data}`)
```elixir
# Wrong
{:ok, line} = IO.gets("Prompt: ")

# Correct - returns data directly or :eof
line = IO.gets("Prompt: ")
```
- Write operations → `:ok` (not printed output)

**ETS** (⚠️ P1):
- `:ets.new/2` → table identifier directly (never `{:ok, table}`)
```elixir
# Wrong
{:ok, table} = :ets.new(:my_table, [:set])

# Correct
table = :ets.new(:my_table, [:set])
```

**File module** (⚠️ P2):
- Bang functions raise `File.Error`, **NOT** `RuntimeError`
```elixir
# Correct exception handling
try do
  File.read!("missing.txt")
rescue
  File.Error -> :handle_file_error
end
```

### Non-existent Functions (⚠️ P1)

**String module**:
- `String.titleize/1` - does NOT exist (implement custom or use library)
```elixir
# No built-in titleize - implement yourself
def titleize(string) do
  string
  |> String.split()
  |> Enum.map(&String.capitalize/1)
  |> Enum.join(" ")
end
```

- `String.empty?/1` - does NOT exist (use `String.length/1 == 0`)
```elixir
# Wrong
String.empty?(str)

# Correct options
str == ""
String.length(str) == 0
byte_size(str) == 0  # fastest
```

**Integer module** (⚠️ P1) - these are in Kernel:
- `div/2`, `rem/2`, `floor/1`, `ceil/1`, `round/1` - NOT in Integer
```elixir
# Wrong
Integer.div(10, 3)
Integer.floor(5.7)

# Correct - these are in Kernel
div(10, 3)      # 3
floor(5.7)      # 5
ceil(5.2)       # 6
round(5.5)      # 6
rem(10, 3)      # 1
```

- Bitwise operators - NOT in Integer (use Kernel: `&&&`, `|||`, `^^^`, `~~~`, `<<<`, `>>>`)
```elixir
# Wrong
Integer.band(5, 3)

# Correct - use operators from Kernel or Bitwise module
use Bitwise
5 &&& 3         # 1 (bitwise AND)
band(5, 3)      # 1 (Bitwise function)
```

**IO module** (⚠️ P1):
- `IO.read(device, :all)` - does NOT exist (valid: `:eof`, `:line`, or integer)
```elixir
# Wrong
IO.read(device, :all)

# Correct options
IO.read(device, :eof)     # Read until EOF
IO.read(device, :line)    # Read one line
IO.read(device, 100)      # Read 100 characters
```

- `:standard_error` - WRONG (use `:stderr`)
```elixir
# Wrong
IO.puts(:standard_error, "Error!")

# Correct
IO.puts(:stderr, "Error!")
```

**Supervisor**:
- `:simple_one_for_one` - DEPRECATED (use `DynamicSupervisor`)

**Regex**:
- `Regex.replace_prefix/3`, `Regex.replace_suffix/3` - do NOT exist

**Tuple module**:
- `Tuple.append/2` - does NOT exist

**MapSet module**:
- `MapSet.empty?/1`, `MapSet.superset?/2` - do NOT exist

**Date module**:
- `Date.local_today/0`, `Date.quarter/1` - do NOT exist
- `Date.Range.new/2,3` - do NOT exist (use `Date.range/2,3`)

**Time module**:
- `Time.from_microseconds_after_midnight/1`, `Time.to_hour/1`, `Time.to_minute/1` - do NOT exist

**Path module**:
- `Path.absname?/1`, `Path.relative?/1`, `Path.safe?/1`, `Path.sep/0` - do NOT exist

**Float module**:
- `Float.parse/2`, `Float.to_string/2`, `Float.is_nan/1`, `Float.is_infinite/1` - do NOT exist

**IO.ANSI module**:
- `blink/0`, `reset_attributes/0`, `save_cursor/0`, `restore_cursor/0` - do NOT exist

**PartitionSupervisor**:
- `whereis_child/2`, `add_partitions/2`, `remove_partitions/2` - do NOT exist

**Access module misunderstood**:
- LLMs document "optimization" instead of actual module (key-based access via `data[key]`)

### Wrong Arity/Signatures

**Process**:
- `spawn/1`, `spawn_link/1` - do NOT exist (use `spawn/2`, `spawn/4`)

**File**:
- `File.read/2` - does NOT exist (only `File.read/1`)

**Stream**:
- `take_every/2` - correct (not `/3`)

**Process spawn functions**:
- `spawn/2`, `spawn/4` return `pid()` directly, NOT `{:ok, pid}`
- With `:monitor` option: `spawn/2,4` return `{pid, reference}` tuple

**File operations**:
- `File.open/2` with `[:write]` does NOT auto-truncate (requires `[:write, :truncate]`)

**Range**:
- Access via struct fields `range.first`, `range.last` - NO `Range.first/1`, `Range.last/1` functions

**Float rounding**:
- `Float.ceil/1`, `Float.floor/1`, `Float.round/1` - do NOT exist (only arity 2 versions)
- All return `float()`, not `integer()`

**DateTime**:
- Many functions need time zone database parameter (not optional)
- `DateTime.now/2` (not /1), `DateTime.shift_zone/3` (not /2)

**NaiveDateTime**:
- `new/8` (not /7) - includes calendar parameter
- `from_erl/3` (not /2) - includes microsecond and calendar

## Module Scope Errors

### Document Actual Module Purpose, Not Tutorials

**Atom module** - Only conversion utilities:
- `to_string/1`, `to_charlist/1` (that's it!)

**Code module** - Runtime compilation/evaluation utilities, NOT syntax guide

**Module module** - Compile-time manipulation functions, NOT general module guide

**Exception module** - Formatting exceptions/stacktraces, NOT exception handling patterns

**Behaviour module** - DEPRECATED (use `@callback` and `@macrocallback` attributes)

**Calendar.TimeZoneDatabase** - Behaviour module defining callbacks, NOT implementation

**Code.Fragment** - Cursor context analysis for IDEs, NOT general parsing

**PartitionSupervisor** - NOT a behaviour with `use` and `init/1` (it's a supervisor)

**File.Stream, IO.Stream** - Structs returned by functions, NOT modules with their own functions

**GenEvent module** - DEPRECATED (use `:gen_event`, GenStage, or Supervisor+GenServers)

### Function Location Mistakes

Functions frequently misplaced in wrong modules - verify actual location:
- Control flow (`case`, `cond`) → Kernel.SpecialForms, NOT Kernel
- I/O operations → IO module, NOT Kernel
- Basic math/comparison → Kernel, NOT specialized modules

## Missing Critical Concepts

### GenServer (⚠️ P2 - Critical Misunderstanding)
- `terminate/2` is **NOT guaranteed** to be called
```elixir
# Wrong - unreliable cleanup
def terminate(_reason, state) do
  close_database(state.db)  # May never run!
end

# Correct - use process links/monitors
def init(args) do
  # Link critical resources
  Process.flag(:trap_exit, true)
  # Or better: use proper supervision
  {:ok, state}
end
```

- Important cleanup should use links/monitors
- Missing callback: `handle_continue/2` for post-init work
```elixir
def init(args) do
  # Defer heavy work to handle_continue
  {:ok, args, {:continue, :load_data}}
end

def handle_continue(:load_data, state) do
  # Heavy initialization here
  data = load_large_dataset()
  {:noreply, Map.put(state, :data, data)}
end
```

- Missing function: `reply/2` for deferred replies
```elixir
def handle_call(:async_work, from, state) do
  # Start async work, reply later
  spawn(fn ->
    result = do_work()
    GenServer.reply(from, result)
  end)
  {:noreply, state}
end
```

### Protocols (⚠️ P2)
- Dispatching ALWAYS on **first argument only**
```elixir
# Wrong - cannot dispatch on second argument
defprotocol Converter do
  def convert(data, format)  # 'format' can't affect dispatch!
end

# Correct - dispatch only on first arg
defprotocol Converter do
  def convert(data)  # Dispatches based on 'data' type only
end
```

- Structs **don't inherit** Map implementations
```elixir
defmodule User do
  defstruct [:name, :age]
end

# Wrong assumption - struct doesn't use Map protocol impl
# Must implement explicitly for User struct
defimpl MyProtocol, for: User do
  def my_function(%User{} = user), do: # custom impl
end
```

- Built-in protocols: Call `inspect(value)`, `to_string(value)` directly, **NOT** `Inspect.inspect(value)`
```elixir
# Wrong
Inspect.inspect(my_value)
String.Chars.to_string(my_value)

# Correct - use Kernel functions
inspect(my_value)
to_string(my_value)
```

- `@fallback_to_any` attribute enables `Any` implementation
```elixir
defprotocol MyProtocol do
  @fallback_to_any true
  def do_something(data)
end

# Fallback for any type
defimpl MyProtocol, for: Any do
  def do_something(_), do: :default
end
```

### Registry
- **LOCAL ONLY** - does NOT work across cluster nodes
- Key comparison uses `===/2`, not `==/2`
- Automatic cleanup: ALL keys removed when process dies

### Application
- **Don't read/modify other apps' environments** (global state, stale dependencies)
- `compile_env/3` for build-time, `get_env/3` for runtime
- Restart types: `:permanent`, `:transient`, `:temporary`

### Agent
- Client/Server separation: Functions execute **inside agent process**
- Expensive operations **block entire agent**
- Anonymous functions only work with same module version (use MFA for distributed)

### String/Unicode
- `String.length/1` counts **graphemes**, `byte_size/1` counts bytes
- Grapheme clusters (UAX #29): single "character" may be multiple code points
- `to_atom/1` causes atom table leaks with untrusted input

### Process
- `Process.exit(pid, :normal)` doesn't exit process (except for caller)
- `Process.exit(pid, :kill)` unconditionally exits
- Process aliases (OTP 24+): `Process.alias/0,1`, `Process.unalias/1`

### Task
- `await/1` can only be called **once** per task
- `async_nolink/2` tasks cannot use `await` (use `yield/2` + `shutdown/2`)
- All data **completely copied** to task processes

### Enumerable Protocol
- `count/1` returns `{:ok, count} | {:error, module}`, NOT raw integer
- `member?/2` returns `{:ok, boolean} | {:error, module}`, NOT raw boolean
- `reduce/3` returns `{:done, term} | {:halted, term} | {:suspended, term, continuation}`
- Has 4 required functions: `count/1`, `member?/2`, `reduce/3`, `slice/1`

### Collectable Protocol
- Collector function signature: `fn acc, {:cont, item} -> ... end`
- **WRONG**: `fn :cont, acc, item -> ... end` (parameter order matters!)
- Command structure: `{:cont, item}` NOT `:cont, item`

### Inspect Protocol
- Returns algebra documents, NOT strings
- **NEVER** call `inspect/2` directly in implementations (infinite recursion)
- Use `Inspect.Algebra.to_doc/2` for nested inspection

### Access Module
- Provides `data[key]` syntax support via behaviour
- Functions: `get_in/2`, `put_in/3`, `update_in/3`, `get_and_update_in/3`, `pop_in/2`
- Access functions: `all/0`, `at/1`, `key/2`, `filter/1`, `elem/0` (NOT optimization patterns!)

### DynamicSupervisor
- **ONLY** supports `:one_for_one` strategy (no `:rest_for_one`)
- `terminate_child/2` accepts PID only, NOT ID
- `:id` field ignored in child specs - children managed by PID

### Config Module
- `config/2,3` perform deep merging of keyword lists
- `config_env/0` returns environment (`:dev`, `:test`, `:prod`)
- `read_config/1` reads previous config calls, NOT application environment

### JSON Module (Built-in)
- **Built-in module**, NOT Jason third-party library
- Different API than Jason
- `decode/1` returns `{:ok, term} | {:error, decode_error_reason}` (no `:keys` option)
- `encode_to_iodata!/2` most efficient for IO operations

### DETS vs ETS
- `dets:open_file/1,2` returns `{:ok, table} | {:error, reason}`, NOT raw identifier
- `insert_new/2` returns `true | false`, NOT `:ok`
- All operations involve disk I/O (much slower than ETS)
- Single writer only, multiple readers allowed

### Time Module
- All operations wrap around 24 hours (cyclic behavior)
- `Time.add(~T[23:00:00], 7200)` → `~T[01:00:00]`
- Microsecond uses `{value, precision}` tuples

### System Module
- `System.pid/0` (NOT `System.get_pid/0`)
- `cmd/3` returns `{result, exit_status}` tuple
- **WARNING**: `shell/2` vulnerable to command injection
- Time functions: `os_time/0` (may jump), `system_time/0` (VM view), `monotonic_time/0` (never decreases)

## Type Specifications

### Always Include @spec Annotations

All functions need proper type specifications:
```elixir
@spec function_name(arg_type) :: return_type
@spec at(t(), integer(), default()) :: element() | default()
@spec count(t()) :: non_neg_integer()
@spec frequencies(t()) :: map()
```

### Common Type Definitions

```elixir
# Keyword/Map
@type t() :: [{key(), value()}]
@type key() :: atom()
@type value() :: any()

# Process
@type dest() :: pid() | port() | atom() | {atom(), node()}

# Binding
@type binding() :: [{atom() | tuple(), any()}]

# Registry
@type keys() :: :unique | :duplicate

# Exception
@type kind() :: :error | :exit | :throw | {:EXIT, pid()}
```

## Performance & Behavioral Notes

### Time Complexity
- Keyword lists: **O(n)** operations (slower than maps)
- Map key lookup: **O(log n)**
- Registry `count/1`: **O(1)** (constant time)

### Empty Enumerable Behavior
- `Enum.all?/2` → `true` for empty enumerables
- `Enum.any?/2` → `false` for empty enumerables
- `Enum.max/1`, `Enum.min/1`, `Enum.reduce/2` → raise `Enum.EmptyError`

### Stream Memory
- `dedup/1` - constant memory (compares with last element only)
- `uniq/1` - linear memory (stores all seen elements)
- `uniq/1` on infinite streams → **memory leak**

### File Operations
- Every opened file spawns Erlang process
- `:raw` mode bypasses file server for performance
- `File.cd/1` changes **global state** (race conditions)

## Version-Specific Features

Always check and document version requirements:

### Since 1.17.0
- Keyword: `default/0` type, `intersect/3`

### Since 1.14.0
- Keyword: `from_keys/2`

### Since 1.13.0
- Keyword: `filter/2`, `reject/2`

### Since 1.12.0
- Integer: `extended_gcd/2`, `pow/2`

### Since 1.10.0
- Keyword: `pop!/2`, `pop_values/2`

## Lazy Evaluation Functions

Many modules have `_lazy` variants - don't omit:
- `Map.get_lazy/3`, `Map.put_new_lazy/3`, `Map.pop_lazy/3`, `Map.replace_lazy/3`
- `Keyword.get_lazy/3`, `Keyword.put_new_lazy/3`, `Keyword.pop_lazy/3`, `Keyword.replace_lazy/3`

## Critical Edge Cases

### Map Operations
- `Map.get/2` returns `nil` for both missing keys AND nil values
- `Map.fetch/2` distinguishes: missing → `:error`, nil value → `{:ok, nil}`

### String Operations
- `String.first("")` → `nil` (not `""`)
- Negative indices supported in `split_at/2`, `slice/2`
- Turkish locale (`:turkic`) has special i/I case rules

### List Operations
- `flatten/1` discards empty list elements
- Negative indices count from end in `delete_at/2`, `insert_at/3`, `pop_at/3`
- `first/2`, `last/2` accept default values (v1.12.0+)

### Enum Operations
- Not all functions return lists
- `concat/1` returns `t()` (same type as elements)
- Maps iterate over `{key, value}` tuples with no guaranteed order

### File/IO Edge Cases
- `File.exists?/1` → `false` for broken symlinks
- `File.lstat/2` vs `File.stat/2` (lstat reads link, stat follows)
- `IO.warn/1` cannot be at tail of function (optimization trims stacktrace)

### Process Constraints
- `Process.alive?/1` raises `ArgumentError` for remote PIDs
- Registration only works on local node
- Process can only have one registered name

### Error Type Confusions
- `map[:nonexistent_key]` returns `nil`, does NOT raise `KeyError`
- `KeyError` only raised by `Map.fetch!/2`, `Keyword.fetch!/2`, and `Access.fetch!/2`
- `Enum.at/2` returns `nil` for out-of-bounds, does NOT raise `Enum.OutOfBoundsError`
- Function clause mismatches raise `FunctionClauseError`, NOT `MatchError`
- `ErlangError` only wraps unmapped Erlang errors (`:badarg` becomes `ArgumentError`)

### Struct Field Errors
- `Code.LoadError` has ONLY `:file` and `:reason` fields (NO `:line`, `:description`)
- `BadFunctionError` has ONLY `:term` field (NO `:function_name`, `:arity`, `:reason`)
- `File.CopyError` uses `:source` and `:destination` (NOT `:file` and `:to`)
- `Macro.Env` has NO `:operators` or `:stacktrace` fields
- Many `Macro.Env` fields are private and should not be accessed directly

### Opaque Types
- `Version.Requirement.t()` is opaque
- `MapSet` internal structure is opaque
- `HashDict.t()` is opaque - do not expose internal fields

## Missing Functions Pattern

LLMs frequently omit large numbers of functions. Always verify complete API:

**Common omissions**:
- `get_and_update/3` variants
- `from_keys/2` constructor functions
- `split/2`, `split_with/2` operations
- `intersect/2,3` operations
- `equal?/2` comparison functions
- `*!/2` bang variants (raise instead of returning errors)
- `replace/3`, `replace!/3`, `replace_lazy/3` variants
- Timer operations: `send_after/3,4`, `read_timer/1`, `cancel_timer/1,2`
- `Process.monitor/1`, `Process.info/2`
- `Macro.escape/1`, `Macro.var/2`, `Macro.traverse/4`
- Calendar parsing: `parse_date/1`, `parse_time/1`, `parse_naive_datetime/1`
- Inspect.Algebra: `container_doc/6`, `glue/3`, `string/1`, `force_unfit/1`
- Access functions: `all/0`, `at/1`, `key/2`, `filter/1`, `elem/0`
- Task.Supervisor: `async_nolink/*`, `async_stream/*`, `children/1`, `terminate_child/2`

## Compilation & Runtime

### Mix Environment
**CRITICAL**: Never access `Mix.env/0` in `lib/` application code - only in `mix.exs` and config files.

### Module Introspection
- Most `Module.*` functions only work during compilation on **uncompiled modules**
- Use `Kernel.function_exported?/3` for compiled modules

### Protocol Consolidation
- Requires `debug_info: true` for all protocols
- Disable during testing: `consolidate_protocols: Mix.env() != :test`

### Code Loading
- `Code.ensure_compiled!/1` - halts until available (same project)
- `Code.ensure_loaded/1` - loads already compiled module (general use)

## Testing Specifics

- Test files: `<filename>_test.exs` in `test/` directory
- Test helper: `test/test_helper.exs` with `ExUnit.start()`
- Never check for Stream structs (streams have various shapes)

## Structural Comparison Order

`number < atom < reference < function < port < pid < tuple < map < list < bitstring`

## Guard Function Constraints

Only specific functions allowed in guards - verify with Kernel documentation:
- `is_exception/1,2`, `is_non_struct_map/1`, `is_map_key/2`
- `node/0,1`, `self/0`, `map_size/1`, `tuple_size/1`
- `byte_size/1`, `bit_size/1`
- Integer: `is_even/1`, `is_odd/1` are **macros** (guard-safe)

## Built-in Attributes

Document all relevant module attributes:
- Documentation: `@moduledoc`, `@doc`, `@typedoc`
- Behaviors: `@behaviour`, `@impl`, `@callback`, `@macrocallback`, `@optional_callbacks`
- Compile hooks: `@before_compile`, `@after_compile`, `@after_verify`, `@on_definition`
- Typespecs: `@type`, `@typep`, `@opaque`, `@spec`
- Other: `@derive`, `@compile`, `@deprecated`, `@external_resource`

## Common Return Patterns

Verify actual return values - LLMs often assume {:ok, value} tuples:

**Direct returns** (no tuple wrapping):
- Most Enum functions → direct values or lists
- Task.await → result (raises on error)
- Most String functions → strings or nil
- IO read operations → data or :eof or {:error, reason}

**Tuple returns**:
- GenServer callbacks → specific tuple formats
- Task.start_link → {:ok, pid}
- File operations (non-bang) → {:ok, value} | {:error, reason}

## Protocol Types

Protocols automatically create `t/0` type:
```elixir
@spec print_size(Size.t()) :: :ok
```

## Critical Warnings to Include

1. **GenServer**: `terminate/2` not guaranteed to be called
2. **String**: `to_atom/1` leaks atoms with untrusted input
3. **File**: `cd/1` changes global state (race conditions)
4. **IO**: `binwrite/2` corrupts Unicode devices
5. **Registry**: Local only, doesn't work across nodes
6. **Application**: Don't read/modify other apps' environments
7. **Stream**: `uniq/1` on infinite streams causes memory leak
8. **Process**: `exit(pid, :normal)` doesn't exit except for caller
9. **Exception**: `blame/3` is expensive (reads filesystem, parses beam files)

## Deprecated Features LLMs Document Incorrectly

### Deprecated Modules
- `GenEvent` - DEPRECATED (use `:gen_event`, GenStage, or Supervisor+GenServers)
- `Set` - DEPRECATED (use `MapSet`)
- `Dict` - DEPRECATED (use `Map` or `Keyword`)
- `HashDict` - DEPRECATED (use `Map`)
- `HashSet` - DEPRECATED (use `MapSet`)

### Deprecated Syntax
- Single-quoted charlists `'hello'` → use `~c"hello"` sigil
- `~~~` operator → use `bnot/2`
- `List.zip/1` → use `Enum.zip/1`
- Decreasing ranges `3..1` → use explicit step `3..1//-1`

### Deprecated Functions
- `System.cwd/0` → use `File.cwd/0`
- `System.stacktrace/0` → use `__STACKTRACE__`
- Logger: `configure_backend/2`, `add_backend/2`, `enable/1`, `disable/1`

## Behavioral & Semantic Distinctions

### Truthy/Falsy Logic
- **`cond`**: Executes first truthy value (not just `true`)
- Only `nil` and `false` are falsy
- Other values (`0`, `""`, `[]`) are truthy

### Pattern Matching
- Map patterns perform **subset matching**, not exact key matching
- `%{a: 1}` matches `%{a: 1, b: 2}` successfully

### Comprehensions
- Always eager (not lazy)
- Only source enumeration can be lazy
- Generators executed left-to-right

### require Directive
- ONLY needed for macros, NOT regular functions
- Public functions are globally available without `require`
- Example: `require Integer` only for `Integer.is_odd/1` (macro)

### use Directive
- Extension point macro that injects code
- Compiles to: `require Module; Module.__using__(opts)`

### Module Namespace
- All Elixir modules are atoms in `Elixir` namespace
- `String == :"Elixir.String"` is `true`

### Lexical Scope
- All directives (`alias`, `require`, `import`) are lexically scoped
- Changes only affect current function/module scope

### Port Communication
- Message API: `{pid, {:command, binary}}`, `{pid, :close}`, `{pid, {:connect, new_pid}}`
- Port messages: `{port, {:data, data}}`, `{port, :closed}`, `{port, :connected}`
- **Security**: If VM crashes, port processes may continue running

### Node Operations
- `Node.connect/1` and `Node.disconnect/1` return `:ignored` if local node not alive
- Spawn functions return "useless PID" when target node doesn't exist
- All spawn functions inlined by compiler

### Bitwise Module
- Functions (`band/2`, `bor/2`, `bxor/2`, `bnot/1`, `bsl/2`, `bsr/2`) vs operators (`&&&`, `|||`, etc.)
- Both are arithmetic shifts (affect negative numbers)
- ALL raise `ArithmeticError` for non-integers
- ALL usable in guard clauses

### Range Semantics
- `..//` creates ranges with explicit steps (still inclusive, NOT exclusive)
- `1..5//2` includes `[1, 3, 5]`
- Full-slice range: `..` returns collections unchanged
- Empty ranges: positive step with start > end, or negative step with start < end

### OptionParser
- `:strict` takes keyword list, NOT boolean
- Kebab-case converts to underscore atoms: `--source-path` → `:source_path`
- `--no-switch` sets boolean switches to `false`
- Atom leakage prevention: unknown switches only parse if atoms exist

### URI Module
- `URI.new/1` validates (returns tuple), `URI.parse/1` does NOT validate
- `encode_query/2` supports `:www_form` (spaces → `+`) and `:rfc3986` (spaces → `%20`)
- `decode_query/3` takes initial map parameter

### Version Module
- `pre` field can contain integers, not just strings: `[String.t() | non_neg_integer()]`
- Pre-release versions < release versions
- Build segments ignored in comparisons
- Pessimistic operator `~> 2.1.3` → `>= 2.1.3 and < 2.2.0`

## Typespecs Are NOT Set-Theoretic Types

Elixir is implementing its own type system based on set-theoretic types that may eventually replace typespecs. Document this distinction.

### Set-Theoretic Type Syntax
- Uses keywords: `and`, `or`, `not` (NOT function syntax)
- Gradual typing system being introduced
- Different from traditional typespecs

---

## 📋 QUICK USAGE GUIDE

### How to Use This Document

**When generating Elixir code:**
1. First check the **Critical Errors - Top 20** section
2. Verify function existence in the relevant module section
3. Check return types match documented patterns
4. Review behavioral notes for the modules you're using

**Priority Levels:**
- **⚠️ P0**: Code-breaking syntax errors (fix immediately)
- **⚠️ P1**: Non-existent functions/wrong return types (causes runtime errors)
- **⚠️ P2**: Critical behavioral misunderstandings (causes bugs)
- **⚠️ P3**: Performance issues or less common mistakes

**Most Common LLM Mistakes (by category):**

1. **Syntax**: `[h :: t]` instead of `[h | t]`, `string()` type, map update syntax
2. **Functions**: Inventing `String.titleize/1`, `String.empty?/1`, `IO.read/2` with `:all`
3. **Returns**: Wrapping `Task.await/1` in `{:ok, value}`, assuming `ETS.new/2` returns tuple
4. **Behavior**: Relying on `terminate/2`, calling `Task.await/1` multiple times
5. **Types**: Using `string()` instead of `String.t()` or `binary()`

### Verification Checklist

Before finalizing Elixir code, verify:
- [ ] No `::` operator in list patterns (use `|`)
- [ ] `String.t()` or `binary()` for string types (not `string()`)
- [ ] Map updates only on existing keys (or use `Map.put/3`)
- [ ] Functions actually exist in documented modules
- [ ] Return types match documentation (unwrapped vs `{:ok, _}` tuples)
- [ ] `Task.await/1` called only once per task
- [ ] No reliance on `terminate/2` for critical cleanup
- [ ] Protocols dispatch only on first argument
- [ ] `@spec` annotations included for all public functions

---

## 🎯 IMPLEMENTATION NOTES

**For LLM Training/Fine-tuning:**
- Focus on P0/P1 errors first (highest impact)
- Include code examples showing both wrong and correct patterns
- Emphasize return type patterns (most common hallucination)
- Test on common modules: String, Enum, Task, GenServer, Map

**For Documentation Generation:**
- Always include `@spec` annotations
- Verify function existence against official docs
- Check return types carefully (many LLMs default to `{:ok, value}`)
- Include behavioral notes, not just API signatures
- Document version requirements for newer functions

**For Code Review:**
- Search for invented functions (String.titleize, String.empty?, etc.)
- Check list pattern matching for `::` vs `|`
- Verify type specs use correct terminology
- Ensure critical cleanup doesn't rely on `terminate/2`
- Check protocol implementations dispatch on first arg only
