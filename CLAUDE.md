# my_compiler — プロジェクトコンテキスト

## このファイルの目的
Claude.aiでの会話内容をClaude Codeに引き継ぐためのコンテキストファイルです。
作業を再開する際はこのファイルを読んでから始めてください。

---

## プロジェクト概要

- **目標**: Dartで書いたコンパイラが自作言語のソースコードを受け取り、x86_64ネイティブバイナリを出力する
- **実装言語**: Dart 3.x
- **出力ターゲット**: x86_64 Mach-O（macOS）
- **開発者プロフィール**: Flutter開発歴15年。情報工学の学習目的でコンパイラを自作中

## コンパイラのフェーズ構成

```
ソースコード
  → [1] 字句解析 (Lexer)       ← 今ここ
  → [2] 構文解析 (Parser)
  → [3] 意味解析 (Semantic Analysis)
  → [4] コード生成 (Code Generator) → x86_64 アセンブリ (.s)
  → [5] アセンブル + リンク (NASM + ld) → 実行バイナリ (Mach-O)
```

---

## 現在の作業状況

**フェーズ: 字句解析 (Lexer) — 実装開始前**

### 完了済み
- macOS環境構築の方針確定
  - NASM: `brew install nasm`
  - binutils: `brew install binutils`
  - Dart SDK: Flutter SDKに同梱済み
- プロジェクト設計の合意
  - TDDで進める（テストを先に書いてから実装）
  - エラーには必ず行番号・列番号を含める

### 次にやること（Lexerの実装）

以下の3ファイルを作成してTDDで実装を始める。

#### lib/token.dart（実装済みコード）

```dart
enum TokenType {
  // リテラル
  number,

  // 演算子
  plus,   // +
  minus,  // -
  star,   // *
  slash,  // /

  // 区切り文字
  lparen, // (
  rparen, // )

  // 終端
  eof,
}

class Token {
  final TokenType type;
  final String lexeme;   // ソースコード上の元の文字列（"42"など）
  final int line;        // 行番号（エラー報告用）
  final int column;      // 列番号（エラー報告用）

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

#### lib/lexer.dart（骨格のみ・_scanToken()は未実装）

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

  // TODO: 以下を実装する
  // bool _isAtEnd()
  // Token? _scanToken()
  // String _advance()
  // Token _makeToken(TokenType type)
}
```

#### test/lexer_test.dart（テストコード）

```dart
import 'package:test/test.dart';
import '../lib/lexer.dart';
import '../lib/token.dart';

void main() {
  group('Lexer', () {
    test('単純な加算をトークナイズできる', () {
      final tokens = Lexer('3 + 4').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].lexeme, '3');
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[2].lexeme, '4');
      expect(tokens[3].type, TokenType.eof);
    });

    test('複数桁の数値をトークナイズできる', () {
      final tokens = Lexer('123').tokenize();
      expect(tokens[0].lexeme, '123');
    });

    test('括弧をトークナイズできる', () {
      final tokens = Lexer('(1 + 2)').tokenize();
      expect(tokens[0].type, TokenType.lparen);
      expect(tokens[4].type, TokenType.rparen);
    });

    test('未知の文字でLexerExceptionを投げる', () {
      expect(() => Lexer('@').tokenize(), throwsA(isA<LexerException>()));
    });
  });
}
```

---

## ディレクトリ構成

```
my_compiler/
├── CLAUDE.md           ← このファイル
├── pubspec.yaml
├── lib/
│   ├── token.dart
│   └── lexer.dart
└── test/
    └── lexer_test.dart
```

## pubspec.yaml の dev_dependencies

```yaml
dev_dependencies:
  test: ^1.24.0
```

---

## 開発方針・ルール

- **TDDで進める**: テストが失敗する状態を確認してから実装する
- **エラーには必ず行番号・列番号を含める**
- **各フェーズが完成したらテストが全部通ることを確認してから次へ**
- **コード生成前にインタプリタとして動かす中間マイルストーンを置く**
- **説明は詳細に**: 学習目的のため、なぜそう書くかの理由も説明する

## 回答スタイルの要件

- あいまいな例え話なし
- 具体的・技術的に詳細に説明する
- 理論的な背景（なぜそう設計するか）も都度説明する

---

## 参考資料（手元に用意しておくと良いもの）

- [低レイヤを知りたい人のためのCコンパイラ作成入門](https://www.sigbus.info/compilerbook)（日本語・無料）
- [Crafting Interpreters](https://craftinginterpreters.com/)（英語・無料）
- System V AMD64 ABI仕様書（関数実装フェーズで必要）
