import 'package:test/test.dart';
import 'package:my_compiler/lexer.dart';
import 'package:my_compiler/token.dart';

void main() {
  group('Lexer', () {
    // -------------------------
    // Basic tokenizing
    // -------------------------

    test('can tokenize a simple addition', () {
      final tokens = Lexer('3 + 4').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].lexeme, '3');
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[2].lexeme, '4');
      expect(tokens[3].type, TokenType.eof);
    });

    test('can tokenize a multi-digit number', () {
      final tokens = Lexer('123').tokenize();
      expect(tokens[0].lexeme, '123');
    });

    test('can tokenize parentheses', () {
      final tokens = Lexer('(1 + 2)').tokenize();
      expect(tokens[0].type, TokenType.lparen);
      expect(tokens[4].type, TokenType.rparen);
    });

    test('can tokenize all four arithmetic operators', () {
      final tokens = Lexer('1 + 2 - 3 * 4 / 5').tokenize();
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[3].type, TokenType.minus);
      expect(tokens[5].type, TokenType.star);
      expect(tokens[7].type, TokenType.slash);
    });

    // -------------------------
    // Whitespace, newlines, and tabs
    // -------------------------

    test('can tokenize with multiple spaces', () {
      final tokens = Lexer('1   +   2').tokenize();
      expect(tokens.length, 4); // NUMBER, PLUS, NUMBER, EOF
    });

    test('can tokenize across newlines', () {
      final tokens = Lexer('1\n+\n2').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
    });

    test('can skip tab characters', () {
      final tokens = Lexer('1\t+\t2').tokenize();
      expect(tokens.length, 4);
    });

    // -------------------------
    // Line and column numbers
    // -------------------------

    test('column numbers are recorded correctly', () {
      final tokens = Lexer('1 + 2').tokenize();
      expect(tokens[0].column, 1); // '1' is at column 1
      expect(tokens[1].column, 3); // '+' is at column 3
      expect(tokens[2].column, 5); // '2' is at column 5
    });

    test('line number increments after a newline', () {
      final tokens = Lexer('1\n+\n2').tokenize();
      expect(tokens[0].line, 1);
      expect(tokens[1].line, 2);
      expect(tokens[2].line, 3);
    });

    test('column number resets to 1 after a newline', () {
      final tokens = Lexer('1\n2').tokenize();
      expect(tokens[1].column, 1);
    });

    // -------------------------
    // Number literal boundaries
    // -------------------------

    test('can tokenize a lone zero', () {
      final tokens = Lexer('0').tokenize();
      expect(tokens[0].lexeme, '0');
    });

    test('empty string returns only EOF', () {
      final tokens = Lexer('').tokenize();
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });

    // -------------------------
    // Error cases
    // -------------------------

    test('throws LexerException on unknown character', () {
      expect(() => Lexer('@').tokenize(), throwsA(isA<LexerException>()));
    });

    test('error includes correct line and column numbers', () {
      try {
        Lexer('1\n@').tokenize();
        fail('expected an exception but none was thrown');
      } on LexerException catch (e) {
        expect(e.line, 2);
        expect(e.column, 1);
      }
    });
  });

  group('Lexer - variable and sentence', () {
    // -------------------------
    // Keywords
    // -------------------------
    test('can tokenize the let keyword', () {
      final tokens = Lexer('let').tokenize();
      expect(tokens[0].type, TokenType.let);
      expect(tokens[0].lexeme, 'let');
      expect(tokens[1].type, TokenType.eof);
    });

    test('let keyword is not treated as an identifier', () {
      final tokens = Lexer('let').tokenize();
      expect(tokens[0].type, isNot(TokenType.identifier));
    });

    // -------------------------
    // Identifiers
    // -------------------------
    test('can tokenize a single-character identifier', () {
      final tokens = Lexer('x').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, 'x');
    });

    test('can tokenize a multi-character identifier', () {
      final tokens = Lexer('foo').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, 'foo');
    });

    test('can tokenize an identifier containing digits', () {
      final tokens = Lexer('x1').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, 'x1');
    });

    test('identifier cannot start with a digit', () {
      // '1x' should tokenize as NUMBER '1' followed by IDENTIFIER 'x',
      // not as a single identifier '1x'
      final tokens = Lexer('1x').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].lexeme, '1');
      expect(tokens[1].type, TokenType.identifier);
      expect(tokens[1].lexeme, 'x');
    });

    test('can tokenize an identifier with underscores', () {
      final tokens = Lexer('my_var').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, 'my_var');
    });

    test('identifier starting with underscore is valid', () {
      final tokens = Lexer('_x').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, '_x');
    });

    // -------------------------
    // Assignment and semicolon
    // -------------------------
    test('can tokenize the assign operator', () {
      final tokens = Lexer('=').tokenize();
      expect(tokens[0].type, TokenType.assign);
      expect(tokens[0].lexeme, '=');
    });

    test('can tokenize a semicolon', () {
      final tokens = Lexer(';').tokenize();
      expect(tokens[0].type, TokenType.semicolon);
      expect(tokens[0].lexeme, ';');
    });

    // -------------------------
    // Variable declaration (full tokenization)
    // -------------------------
    test('can tokenize a full variable declaration', () {
      final tokens = Lexer('let x = 5;').tokenize();
      expect(tokens[0].type, TokenType.let);
      expect(tokens[1].type, TokenType.identifier);
      expect(tokens[1].lexeme, 'x');
      expect(tokens[2].type, TokenType.assign);
      expect(tokens[3].type, TokenType.number);
      expect(tokens[3].lexeme, '5');
      expect(tokens[4].type, TokenType.semicolon);
      expect(tokens[5].type, TokenType.eof);
    });

    test('can tokenize two variable declarations', () {
      final tokens = Lexer('let x = 1;\nlet y = 2;').tokenize();
      expect(tokens[0].type, TokenType.let); // let
      expect(tokens[1].type, TokenType.identifier); // x
      expect(tokens[2].type, TokenType.assign); // =
      expect(tokens[3].type, TokenType.number); // 1
      expect(tokens[4].type, TokenType.semicolon); // ;
      expect(tokens[5].type, TokenType.let); // let
      expect(tokens[6].type, TokenType.identifier); // y
    });

    test('can tokenize a variable reference in an expression', () {
      final tokens = Lexer('x + 1').tokenize();
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, 'x');
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
    });
  });
}
