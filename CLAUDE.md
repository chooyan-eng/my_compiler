# my_compiler — Project Context

## Purpose of This File
This is a context file for handing off conversation content from Claude.ai to Claude Code.
Read this file before resuming work.

---

## Project Overview

- **Goal**: A compiler written in Dart that accepts source code in a custom language and outputs x86_64 native binaries
- **Implementation language**: Dart 3.x
- **Output target**: x86_64 Mach-O (macOS)
- **Developer profile**: 15 years of Flutter development. Building a compiler for educational purposes in computer science

## Compiler Phase Structure

```
Source code
  → [1] Lexical analysis (Lexer)       ← current phase
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

### Next Steps (Lexer implementation)

Create the following 3 files and start TDD implementation.

#### lib/token.dart (implemented code)

```dart
enum TokenType {
  // Literals
  number,

  // Operators
  plus,   // +
  minus,  // -
  star,   // *
  slash,  // /

  // Delimiters
  lparen, // (
  rparen, // )

  // End of file
  eof,
}

class Token {
  final TokenType type;
  final String lexeme;   // The original string in source code (e.g., "42")
  final int line;        // Line number (for error reporting)
  final int column;      // Column number (for error reporting)

  const Token({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.column,
  });

  @override
  String toString() => 'Token($type, "$lexeme", $line:$column)';
}
```

#### lib/lexer.dart (skeleton only — _scanToken() not yet implemented)

```dart
import 'token.dart';

class LexerException implements Exception {
  final String message;
  final int line;
  final int column;

  LexerException(this.message, this.line, this.column);

  @override
  String toString() => 'LexerError at $line:$column → $message';
}

class Lexer {
  final String source;
  int _start = 0;
  int _current = 0;
  int _line = 1;
  int _column = 1;

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _start = _current;
      final token = _scanToken();
      if (token != null) tokens.add(token);
    }

    tokens.add(Token(
      type: TokenType.eof,
      lexeme: '',
      line: _line,
      column: _column,
    ));

    return tokens;
  }

  // TODO: implement the following
  // bool _isAtEnd()
  // Token? _scanToken()
  // String _advance()
  // Token _makeToken(TokenType type)
}
```

#### test/lexer_test.dart (test code)

```dart
import 'package:test/test.dart';
import '../lib/lexer.dart';
import '../lib/token.dart';

void main() {
  group('Lexer', () {
    test('tokenizes a simple addition expression', () {
      final tokens = Lexer('3 + 4').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].lexeme, '3');
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[2].lexeme, '4');
      expect(tokens[3].type, TokenType.eof);
    });

    test('tokenizes a multi-digit number', () {
      final tokens = Lexer('123').tokenize();
      expect(tokens[0].lexeme, '123');
    });

    test('tokenizes parentheses', () {
      final tokens = Lexer('(1 + 2)').tokenize();
      expect(tokens[0].type, TokenType.lparen);
      expect(tokens[4].type, TokenType.rparen);
    });

    test('throws LexerException for an unknown character', () {
      expect(() => Lexer('@').tokenize(), throwsA(isA<LexerException>()));
    });
  });
}
```

---

## Directory Structure

```
my_compiler/
├── CLAUDE.md           ← this file
├── pubspec.yaml
├── lib/
│   ├── token.dart
│   └── lexer.dart
└── test/
    └── lexer_test.dart
```

## pubspec.yaml dev_dependencies

```yaml
dev_dependencies:
  test: ^1.24.0
```

---

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
