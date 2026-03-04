# my_compiler — Project Context

## Project Overview

- **Goal**: A compiler written in Dart that accepts source code in a custom language and outputs x86_64 native binaries
- **Implementation language**: Dart 3.x
- **Output target**: x86_64 Mach-O (macOS)
- **Developer profile**: 15 years of Flutter development. Building a compiler for educational purposes in computer science

## Compiler Phase Structure

```
Source code
  → [1] Lexical analysis (Lexer)
  → [2] Syntax analysis (Parser)
  → [3] Semantic analysis
  → [4] Code generation (Code Generator) → x86_64 assembly (.s)
  → [5] Assemble + link (NASM + ld) → executable binary (Mach-O)
```

---

## Current Status

**Phase: Lexical analysis (Lexer) — before implementation**

### Completed
- macOS environment setup finalized
  - NASM: `brew install nasm`
  - binutils: `brew install binutils`
  - Dart SDK: bundled with Flutter SDK
- Project design agreed upon
  - Proceed with TDD (write tests before implementation)
  - All errors must include line and column numbers

## Development Policy and Rules

- **Proceed with TDD**: confirm tests are failing before implementing
- **All errors must include line and column numbers**
- **After each phase is complete, confirm all tests pass before moving to the next**
- **Set an intermediate milestone to run as an interpreter before code generation**
- **Explain in detail**: since this is for learning, also explain the reasoning behind design decisions
- **Write all comments, identifiers, commit messages, and any other text in code in English, regardless of the language used in the prompt**

## Response Style Requirements

- No vague analogies
- Explain concretely and in technical detail
- Also explain the theoretical background (why things are designed the way they are) as needed

---

## Reference Materials

- [Low-Layer C Compiler Creation Guide](https://www.sigbus.info/compilerbook) (Japanese, free)
- [Crafting Interpreters](https://craftinginterpreters.com/) (English, free)
- System V AMD64 ABI specification (needed for the function implementation phase)
