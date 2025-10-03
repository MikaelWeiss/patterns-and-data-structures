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
