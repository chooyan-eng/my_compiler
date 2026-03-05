import 'package:test/test.dart';
import '../lib/lexer.dart';
import '../lib/token.dart';

void main() {
  group('Lexer', () {
    // -------------------------
    // 基本的なトークナイズ
    // -------------------------

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

    test('四則演算子をすべてトークナイズできる', () {
      final tokens = Lexer('1 + 2 - 3 * 4 / 5').tokenize();
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[3].type, TokenType.minus);
      expect(tokens[5].type, TokenType.star);
      expect(tokens[7].type, TokenType.slash);
    });

    // -------------------------
    // 空白・改行・タブ
    // -------------------------

    test('空白が複数あってもトークナイズできる', () {
      final tokens = Lexer('1   +   2').tokenize();
      expect(tokens.length, 4); // NUMBER, PLUS, NUMBER, EOF
    });

    test('改行をまたいでもトークナイズできる', () {
      final tokens = Lexer('1\n+\n2').tokenize();
      expect(tokens[0].type, TokenType.number);
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
    });

    test('タブ文字をスキップできる', () {
      final tokens = Lexer('1\t+\t2').tokenize();
      expect(tokens.length, 4);
    });

    // -------------------------
    // 行番号・列番号
    // -------------------------

    test('列番号が正しく記録される', () {
      final tokens = Lexer('1 + 2').tokenize();
      expect(tokens[0].column, 1); // '1' は1列目
      expect(tokens[1].column, 3); // '+' は3列目
      expect(tokens[2].column, 5); // '2' は5列目
    });

    test('改行後に行番号がインクリメントされる', () {
      final tokens = Lexer('1\n+\n2').tokenize();
      expect(tokens[0].line, 1);
      expect(tokens[1].line, 2);
      expect(tokens[2].line, 3);
    });

    test('改行後に列番号が1にリセットされる', () {
      final tokens = Lexer('1\n2').tokenize();
      expect(tokens[1].column, 1);
    });

    // -------------------------
    // 数値リテラルの境界
    // -------------------------

    test('0単体をトークナイズできる', () {
      final tokens = Lexer('0').tokenize();
      expect(tokens[0].lexeme, '0');
    });

    test('空文字列はEOFのみを返す', () {
      final tokens = Lexer('').tokenize();
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });

    // -------------------------
    // エラー系
    // -------------------------

    test('未知の文字でLexerExceptionを投げる', () {
      expect(() => Lexer('@').tokenize(), throwsA(isA<LexerException>()));
    });

    test('エラーに正しい行番号・列番号が含まれる', () {
      try {
        Lexer('1\n@').tokenize();
        fail('例外が発生しなかった');
      } on LexerException catch (e) {
        expect(e.line, 2);
        expect(e.column, 1);
      }
    });
  });
}
