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
