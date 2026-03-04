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
