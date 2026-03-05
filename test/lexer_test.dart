import 'package:test/test.dart';
import '../lib/lexer.dart';
import '../lib/token.dart';

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
}
