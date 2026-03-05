// test/parser_test.dart

import 'package:test/test.dart';
import 'package:my_compiler/lexer.dart';
import 'package:my_compiler/parser.dart';
import 'package:my_compiler/ast.dart';
import 'package:my_compiler/token.dart';

/// Convenience: lex and parse in one step.
Expr parse(String source) => Parser(Lexer(source).tokenize()).parse();

void main() {
  group('Parser', () {
    // -------------------------
    // 数値リテラル
    // -------------------------

    test('単一の数値をパースできる', () {
      final expr = parse('42');
      expect(expr, isA<NumberExpr>());
      expect((expr as NumberExpr).value, 42);
    });

    // -------------------------
    // 二項演算
    // -------------------------

    test('加算をパースできる', () {
      final expr = parse('1 + 2') as BinaryExpr;
      expect(expr.op.type, TokenType.plus);
      expect((expr.left as NumberExpr).value, 1);
      expect((expr.right as NumberExpr).value, 2);
    });

    test('減算をパースできる', () {
      final expr = parse('5 - 3') as BinaryExpr;
      expect(expr.op.type, TokenType.minus);
    });

    test('乗算をパースできる', () {
      final expr = parse('3 * 4') as BinaryExpr;
      expect(expr.op.type, TokenType.star);
    });

    test('除算をパースできる', () {
      final expr = parse('8 / 2') as BinaryExpr;
      expect(expr.op.type, TokenType.slash);
    });

    // -------------------------
    // 演算子の優先順位
    // -------------------------

    test('乗算は加算より優先される', () {
      // 1 + 2 * 3 は (1 + (2 * 3)) にパースされる
      final expr = parse('1 + 2 * 3') as BinaryExpr;
      expect(expr.op.type, TokenType.plus); // ルートは +
      expect(expr.right, isA<BinaryExpr>());
      expect((expr.right as BinaryExpr).op.type, TokenType.star); // 右辺が *
    });

    test('除算は減算より優先される', () {
      // 6 - 4 / 2 は (6 - (4 / 2)) にパースされる
      final expr = parse('6 - 4 / 2') as BinaryExpr;
      expect(expr.op.type, TokenType.minus);
      expect((expr.right as BinaryExpr).op.type, TokenType.slash);
    });

    test('加算は左結合である', () {
      // 1 + 2 + 3 は ((1 + 2) + 3) にパースされる
      final expr = parse('1 + 2 + 3') as BinaryExpr;
      expect(expr.op.type, TokenType.plus);
      expect(expr.left, isA<BinaryExpr>()); // 左辺が (1 + 2)
    });

    // -------------------------
    // 括弧
    // -------------------------

    test('括弧で優先順位を変えられる', () {
      // (1 + 2) * 3 のルートは * でなければならない
      final expr = parse('(1 + 2) * 3') as BinaryExpr;
      expect(expr.op.type, TokenType.star); // ルートは *
      expect(expr.left, isA<BinaryExpr>());
      expect((expr.left as BinaryExpr).op.type, TokenType.plus);
    });

    test('ネストした括弧をパースできる', () {
      final expr = parse('((1 + 2))');
      expect(expr, isA<BinaryExpr>());
    });

    // -------------------------
    // 単項マイナス
    // -------------------------

    test('単項マイナスをパースできる', () {
      final expr = parse('-3') as UnaryExpr;
      expect(expr.op.type, TokenType.minus);
      expect((expr.operand as NumberExpr).value, 3);
    });

    test('単項マイナスは乗算より優先される', () {
      // -3 * 2 は (-3) * 2 にパースされる
      final expr = parse('-3 * 2') as BinaryExpr;
      expect(expr.op.type, TokenType.star);
      expect(expr.left, isA<UnaryExpr>());
    });

    test('単項マイナスが括弧に適用できる', () {
      final expr = parse('-(1 + 2)') as UnaryExpr;
      expect(expr.operand, isA<BinaryExpr>());
    });

    test('単項マイナスを連続で適用できる', () {
      // --3 は -(-3) にパースされる
      final expr = parse('--3') as UnaryExpr;
      expect(expr.operand, isA<UnaryExpr>());
    });

    // -------------------------
    // エラー系
    // -------------------------

    test('対応する閉じ括弧がない場合にParseExceptionを投げる', () {
      expect(() => parse('(1 + 2'), throwsA(isA<ParseException>()));
    });

    test('演算子の右辺がない場合にParseExceptionを投げる', () {
      expect(() => parse('1 +'), throwsA(isA<ParseException>()));
    });

    test('数値が連続している場合にParseExceptionを投げる', () {
      expect(() => parse('1 2'), throwsA(isA<ParseException>()));
    });

    test('空の括弧はParseExceptionを投げる', () {
      expect(() => parse('()'), throwsA(isA<ParseException>()));
    });
  });
}
