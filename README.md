# hoc — Higher-Order Calculator

A step-by-step implementation of the classic **hoc** interpreter, built in C using `yacc` and `lex`, following Kernighan & Pike's *The Unix Programming Environment* (1984). Each version adds a new layer of compiler functionality on top of the last.

---

## Versions

### hoc1 — Basic Arithmetic
The simplest version. Parses and evaluates arithmetic expressions directly in the grammar actions.

**Features:**
- Addition, subtraction, multiplication, division (`+ - * /`)
- Parenthesised expressions
- Floating-point numbers

---

### hoc2 — Variables and Error Recovery
Introduces mutable state and robustness.

**Features:**
- Single-letter variables `a`–`z` backed by a `double mem[26]` array
- Unary minus (`-x`)
- Assignment expressions (`a = 3 + 2`)
- Error recovery using `setjmp`/`longjmp` — a bad expression doesn't crash the program
- Division-by-zero detection
- Floating-point exception handling via `SIGFPE`

---

### hoc3 — Symbol Table and Built-in Functions
Replaces the fixed variable array with a proper hash-chained symbol table, and adds a math library.

**Features:**
- Named variables of arbitrary length (`velocity`, `total`, etc.)
- Symbol table with `install()` and `lookup()` (linked list)
- Built-in mathematical functions: `sin`, `cos`, `atan`, `log`, `log10`, `exp`, `sqrt`, `int`, `abs`
- Built-in constants: `PI`, `E`, `GAMMA`, `DEG`, `PHI`
- Error-checked math operations (domain and range errors via `errno`)
- Undefined variable detection at runtime

---

### hoc4 — Bytecode Compiler and Virtual Machine
The most complete version. Instead of evaluating expressions directly during parsing, hoc4 compiles them to bytecode and executes them on a stack-based virtual machine.

**Features:**
- **Code generation** — the parser emits `Inst` (function pointer) arrays into a `prog[]` buffer
- **Stack-based VM** — `execute()` walks `prog[]`, dispatching each instruction
- **Instruction set:**
  - `constpush` — push a numeric literal onto the stack
  - `varpush` — push a variable reference onto the stack
  - `evalop` — dereference a variable to its value
  - `assign` — pop a value and a variable, store the value
  - `addop`, `subop`, `mulop`, `divop` — binary arithmetic
  - `negateop` — unary minus
  - `powerop` — exponentiation (`^`)
  - `bltin` — call a built-in function (e.g. `sin`, `sqrt`)
  - `print` — print the top of the stack
  - `pop` — discard the top of the stack
- **Disassembler** (`dis.c`) — after each parse, `disassemble()` walks `prog[]` and prints a human-readable listing of the generated instructions before execution
- Everything from hoc3: symbol table, built-in functions and constants, error recovery

---

## Building

Each version has its own `makefile`. For hoc4 (requires `bison` and a C99-capable compiler):

```bash
cd hoc4
make hoc4
```

If on macOS and `bison` is missing:
```bash
brew install bison
export PATH="/opt/homebrew/opt/bison/bin:$PATH"
make hoc4
```

---

## Running

```bash
./hoc4
```

The interpreter reads from stdin interactively. Press **Ctrl+D** to exit.

**Example session:**
```
2 + 3
        5
x = 10
sin(x)
        -0.54402111
PI * 2
        6.2831853
2 ^ 8
        256
```

---

## Architecture (hoc4)

```
Source text
    │
    ▼
 yylex()          — tokeniser (hand-written in hoc.y)
    │
    ▼
 yyparse()         — yacc grammar (hoc.y)
    │  emits Inst* via code()
    ▼
 prog[]            — flat array of machine instructions (function pointers)
    │
    ├─▶ disassemble()  — prints human-readable instruction listing (dis.c)
    │
    └─▶ execute()      — walks prog[], dispatches each instruction (code.c)
                          uses a Datum stack for operands
```

---

## Token Types

Token values are assigned by yacc starting at 258 (0–255 are ASCII):

| Value | Token  | Meaning                          |
|-------|--------|----------------------------------|
| 258   | NUMBER | A numeric literal                |
| 259   | VAR    | A variable with an assigned value|
| 260   | BLTIN  | A built-in function              |
| 261   | UNDEF  | A declared but unassigned variable|

---

## File Structure

```
hoc1/   hoc.y                         — grammar + evaluator
hoc2/   hoc.y                         — adds variables, error recovery
hoc3/   hoc.y, hoc.h, symbol.c,
        init.c, math.c                — adds symbol table, builtins
hoc4/   hoc.y, hoc.h, code.c, dis.c,
        symbol.c, init.c, math.c,
        code.h, dis.h, symbol.h,
        init.h                        — adds bytecode VM, disassembler
```

---

## References

- Kernighan, B. W. & Pike, R. (1984). *The Unix Programming Environment*. Prentice Hall.
