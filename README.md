# COMS10016 sandbox

A ready-to-use environment for COMS10016, for writing, running and debugging C and Haskell programs. Everything you need for C (clang, gcc, make, gdb, valgrind, cppcheck, clang-tidy and the SDL2 graphics library) and for Haskell (GHC, cabal, the Haskell Language Server and QuickCheck) is already installed in the dev container. It also includes a lightweight desktop, accessible in your browser through noVNC, for running graphical programs (see [Graphics](#graphics)).

## Prerequisites

- [OrbStack](https://orbstack.dev), to run the container. Other Docker setups work too, but the desktop's web addresses in [Graphics](#graphics) need OrbStack.
- An editor, either:
  - [VS Code](https://code.visualstudio.com) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension, or
  - [Zed](https://zed.dev)

## Getting started

Both editors are set up for building, debugging and formatting, and where they work differently, the instructions below say what to do in each.

1. Open this folder in the container:
   - **VS Code:** open the folder and choose **Reopen in Container** when asked.
   - **Zed:** open the folder and choose **Open in Container** when asked. If you missed the prompt, press <kbd>Ctrl</kbd>+<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>O</kbd> and choose **Connect Dev Container**.
2. Open the editor's built-in terminal (<kbd>Ctrl</kbd>+<kbd>`</kbd> in both editors), and run:

   ```sh
   cd c
   make run
   ```

   You should see `Hello, World!`.
3. Then try Haskell, from the same terminal:

   ```sh
   cd ../haskell
   runghc Hello.hs
   ```

   You should see `Hello, World!` and `+++ OK, passed 100 tests.`

## Folder layout

```
c/                  C, for imperative programming
  src/              your source code: one .c file = one program
  build/            compiled programs (created by make, safe to delete)
  tests/            expected output for make check
  projects/         course projects that come with their own Makefile
  Makefile          build commands
  .clang-format     code formatting style
haskell/            Haskell, for functional programming
  fourmolu.yaml     code formatting style
  hie.yaml          how the editor loads Haskell files
.vscode/            editor, build and debug settings for VS Code
.zed/               editor settings and tasks for Zed
```

## C

Everything for C is in the `c/` folder, and the make commands below run there.

To start a new exercise, create a new file such as `c/src/loops.c` with its own `main` function. You don't need to change the Makefile; it picks up every `.c` file in `src/` automatically. Course work that comes as a folder with its own Makefile goes in `c/projects/` instead (see [Course projects](#course-projects)).

A few names are used by make itself (its commands and the `build` folder), so don't use them for `.c` files: `all`, `run`, `debug`, `memcheck`, `asan`, `check`, `lint`, `format`, `clean`, `help` and `build`. If you do, make stops and asks you to rename the file.

### Make commands

Run these in `c/`, the folder with the Makefile in it. A new terminal starts one level up, in the workspace folder, so run `cd c` first. Anywhere else, such as in the workspace folder or in `c/src/`, make stops with `No rule to make target 'run'` (from `c/src/`, go back with `cd ..`). Course projects are the exception: they're built in their own folder (see [Course projects](#course-projects)).

Replace `NAME` with the file name without `.c`, e.g. `hello` for `c/src/hello.c`.

| Command | What it does |
|---|---|
| `make` | Build every program in `src/` |
| `make NAME` | Build one program into `build/NAME` |
| `make run-NAME` | Build and run it |
| `make debug-NAME` | Build and open it in the gdb debugger |
| `make memcheck-NAME` | Build and run it under valgrind to find memory leaks and invalid memory use |
| `make asan-NAME` | Build with AddressSanitizer and UndefinedBehaviorSanitizer, then run it |
| `make check-NAME` | Build and run it with `tests/NAME.in` as input, and compare its output with `tests/NAME.out` |
| `make lint` | Check all code for common mistakes with cppcheck and clang-tidy |
| `make format` | Format all code in `src/` with clang-format |
| `make clean` | Delete the `build/` folder |
| `make help` | Show the list of commands |

`make run`, `make debug`, `make memcheck`, `make asan` and `make check` without a name use `hello`. To pick another program, pass `P`:

```sh
make run P=loops
```

If the program needs arguments or input, pass them in `ARGS`, written as you would in the terminal. This works with `run`, `debug`, `memcheck` and `asan`:

```sh
make run-loops ARGS="some arguments < input.txt"
```

You can also run a built program directly:

```sh
./build/loops some arguments < input.txt
```

### Compiler settings

Programs are compiled with clang as C11, the same compiler and standard as the course's own Makefiles, with extra warnings turned on:

```
-std=c11 -Wall -Wextra -Wpedantic -Wshadow -Wstrict-prototypes
-Wold-style-definition -Wformat=2 -g -O0 -Dtest_NAME
```

- **Warnings** point out likely bugs. Treat them as errors and fix them. For example, `a function declaration without a prototype is deprecated` means: write `int main(void)`, not `int main()`. In C, empty brackets mean "any arguments", so the compiler can't check calls.
- **`-g -O0`** keeps debug information and turns off optimisation, so the debugger shows exactly what your code does.
- The maths library is linked automatically, so `#include <math.h>` just works.
- **`-Dtest_NAME`** (e.g. `-Dtest_list` for `c/src/list.c`) matches the course's Makefiles. Course files often put their tests and `main` inside `#ifdef test_NAME`, so they only run when that file is built as a program on its own.
- **`-std=c11`** makes only the C standard library available. Functions that come from POSIX (the Unix standard) instead, such as `strdup`, `getline` and `fileno`, are hidden, and using one gives the error `call to undeclared function 'strdup'`. The course compiles your code the same way, so either do without them or put `#define _POSIX_C_SOURCE 200809L` on the first line of the file, before any `#include`. The man page for a function says what it needs: look for "Feature Test Macro Requirements" in, for example, `man 3 strdup`.

Any setting can be changed for one command:

```sh
make CC=gcc run            # use gcc instead of clang
make CSTD=c17 run          # use a newer C standard
```

To add compiler flags, use `EXTRA_CFLAGS`. For example, `-Wconversion` warns when a value is silently converted to a type that can't hold it, such as a `double` stored in an `int`:

```sh
make EXTRA_CFLAGS=-Wconversion run
```

### Building and debugging

With a `.c` file from `c/` open in the editor:

- **VS Code:** <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>B</kbd> builds the file, and errors appear in the **Problems** panel. <kbd>F5</kbd> builds it and starts the debugger; if the build fails, the debugger doesn't start, so fix the errors first. The debugger asks for program arguments: press <kbd>Enter</kbd> for none, or type them as you would in the terminal, e.g. `foo bar < input.txt` to pass two arguments and read input from a file.
- **Zed:** run **task: spawn** (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>R</kbd>) and choose **C: make** to build the file, and **task: rerun** (<kbd>Cmd</kbd>+<kbd>Opt</kbd>+<kbd>R</kbd>) to build it again. To debug, press <kbd>F4</kbd> and choose **C: debug current file** from the `debug.json` entries; it builds the file, then runs it under gdb. Don't pick it from the recently used sessions at the top of the list: those rerun the file they were first started from, and breakpoints in the open file then show "no executable code is associated with this line". Zed can't ask for program arguments, so to pass arguments or input, run `make debug-NAME ARGS="foo bar < input.txt"` in `c/` instead.

In both editors, click to the left of a line number to set a breakpoint.

This also works in a [course project](#course-projects): for `c/projects/list/list.c`, it runs `make list` in `c/projects/list/` using the project's own Makefile, and the program runs in that folder. The program is named after the open file, so open the file that has `main` in it.

### Errors and warnings

Both editors check your code with clang-tidy, using the same warnings as the compiler plus the checks listed in `c/.clang-tidy`, such as using `atoi` without error checking. `make lint` runs the same checks.

- **VS Code:** checks a `.c` file each time you open or save it, and lists what it finds in the **Problems** panel. It also runs clang's static analyser, which finds bugs such as using a pointer that may be `NULL`. When you build, the compiler's own errors and warnings are added to the list, so some problems appear twice, once from each tool. Problems also appear at the end of the line that caused them (the **Error Lens** extension).
- **Zed:** shows problems as you type. It doesn't run clang's static analyser, so a pointer that may be `NULL` isn't flagged; run `make lint` to include it.

### Formatting

Both editors format your code every time you save, using the style in `c/.clang-format` (4-space indents, opening braces on the same line). Braces are added around the body of every `if`, `else`, `for` and `while`, even a single line, so adding a second line later can't accidentally put it outside the block. To format every file at once, run `make format`. Both editors also:

- remove spaces at the end of lines and make sure each file ends with a newline
- draw a guide at 80 characters, the usual maximum line length

### VS Code extras

- **Hex Editor:** to see the raw bytes of any file, right-click it and choose **Open With… → Hex Editor**.
- The `.d` files make creates in `c/build/` are hidden from the file explorer. They only record which headers each program uses.

### Finding memory bugs

A program that seems to work can still have memory bugs. Two tools help find them:

- **`make memcheck-NAME`** (valgrind) reports memory leaks, use of uninitialised values, and reads or writes outside allocated memory. Look for `ERROR SUMMARY: 0 errors` and `All heap blocks were freed` at the end.
- **`make asan-NAME`** (sanitizers) stops the program at the first out-of-bounds access, use-after-free, integer overflow and similar problems, and prints where it happened. It runs much faster than valgrind.

It's worth running both before submitting work.

### Checking output

Many assignments give an example input and the exact output your program should print. To check your program against it:

1. Put the input in `c/tests/NAME.in` (skip this if the program reads no input).
2. Put the expected output in `c/tests/NAME.out`.
3. Run `make check-NAME`.

It prints `PASS`, or `FAIL` with the differing lines: `-` lines are what was expected, `+` lines are what your program printed. Spaces and newlines count, so check the end of lines carefully. `c/tests/hello.out` is an example.

The check also fails if the program crashes or `main` returns anything other than `0`, even when the output is right. What your program printed is saved in `c/build/NAME.actual`.

### Course projects

Some course work, such as an assignment, comes as a folder of files with its own Makefile. Put each one in its own folder in `c/projects/`, e.g. `c/projects/list/`, and build it there with its own Makefile, as the course's instructions say. `c/projects/hellosdl/` is a small example:

```sh
cd c/projects/hellosdl
make
./hellosdl
```

Don't copy a project's files into `c/src/`. make builds each `.c` file there as a separate program, so a file without `main` stops `make` with `undefined reference to 'main'`.

A program in `c/src/` is a single `.c` file. Header files (`.h`) in `c/src/` do work: `#include "myheader.h"` and make will rebuild when they change. For your own program split across several `.c` files, make a folder in `c/projects/` with a Makefile like the one in `c/projects/hellosdl/`, and list all the `.c` files in its `clang` command.

### Graphics

Programs that open windows, such as the course's graphics work with SDL2, show them on a desktop inside the container. To see it:

1. Open <https://vnc.coms10016.local> in a browser, or click **Open the desktop** on the welcome page, <https://welcome.coms10016.local>. These addresses need OrbStack; with other Docker setups, open port 6080 from VS Code's **Ports** panel (next to **Terminal**) instead.
2. Click **Connect**.

Then run the program as usual, from the terminal or from your editor's debugger, and its window appears on the desktop. To check that graphics work, build and run the example project from `c/`; a blue window should appear, and closing it ends the program:

```sh
make -C projects/hellosdl
./projects/hellosdl/hellosdl
```

If the desktop doesn't fit in the browser, open noVNC's settings (the gear in its side bar) and change **Scaling mode**.

Programs that use SDL2 need `-lSDL2` when they are linked, so give them a folder in `c/projects/` with a Makefile, like `c/projects/hellosdl/`.

## Haskell

GHC 9.14.1, cabal 3.16.1.0, the Haskell Language Server 2.14.0.0 and QuickCheck are installed, the versions the course uses. There's no need to run the course's ghcup, `cabal update` or `cabal install --lib QuickCheck` steps.

Put your Haskell files in `haskell/`. `haskell/Hello.hs` is an example with a QuickCheck test. To try out a file, load it into GHCi from that folder, then type an expression to evaluate it:

```sh
cd haskell
ghci Hello.hs
```

```
ghci> double 21
42
ghci> main
```

After changing the file, type `:r` to reload it, and `:q` to quit. To run a file's `main` without GHCi, use `runghc Hello.hs`.

### Running and GHCi

Both editors show errors as you type, and the type of anything you hover over (the **Haskell** extension). With a `.hs` file open:

- **VS Code:** <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>B</kbd> runs the file's `main` with `runghc`, in the terminal. To load the file into GHCi, open the Command Palette (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>), choose **Tasks: Run Task**, then **GHCi: current file**. The terminal opens with the file loaded, ready for `:r` after each change.
- **Zed:** run **task: spawn** (<kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>R</kbd>) and choose **Haskell: run** to run the file's `main` with `runghc`, or **GHCi** to load it into GHCi in a new terminal. **task: rerun** (<kbd>Cmd</kbd>+<kbd>Opt</kbd>+<kbd>R</kbd>) runs the last task again.

The debugger only works for C.

### Evaluating code in the file

In VS Code, you can run code without leaving the file. Write an expression after `-- >>>`, or a QuickCheck property after `-- prop>`, and click **Evaluate…** above it. The result appears on the next line:

```haskell
-- >>> double 21
-- 42

-- prop> \x -> double x == 2 * x
-- +++ OK, passed 100 tests.
```

Click **Refresh…** to run it again after changing the code. `haskell/Hello.hs` has both examples. Zed has no **Evaluate…** button, so try expressions in GHCi instead.

### Files that import each other

Both editors use `haskell/hie.yaml` to load Haskell files, which lets files in `haskell/` import each other. If files in a subfolder, e.g. `haskell/week1/`, import each other, copy `hie.yaml` into that subfolder, then restart the Haskell Language Server: in VS Code, run **Haskell: Restart Haskell LSP server** from the Command Palette; in Zed, run **editor: restart language server**.

### Formatting

Haskell files are formatted every time you save, by [Fourmolu](https://fourmolu.github.io) with the style in `haskell/fourmolu.yaml` (4-space indents). To format every file at once, run this in `haskell/`:

```sh
fourmolu -i *.hs
```
