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
    // Number literals
    // -------------------------

    test('parses a single number', () {
      final expr = parse('42');
      expect(expr, isA<NumberExpr>());
      expect((expr as NumberExpr).value, 42);
    });

    // -------------------------
    // Binary operations
    // -------------------------

    test('parses addition', () {
      final expr = parse('1 + 2') as BinaryExpr;
      expect(expr.op.type, TokenType.plus);
      expect((expr.left as NumberExpr).value, 1);
      expect((expr.right as NumberExpr).value, 2);
    });

    test('parses subtraction', () {
      final expr = parse('5 - 3') as BinaryExpr;
      expect(expr.op.type, TokenType.minus);
    });

    test('parses multiplication', () {
      final expr = parse('3 * 4') as BinaryExpr;
      expect(expr.op.type, TokenType.star);
    });

    test('parses division', () {
      final expr = parse('8 / 2') as BinaryExpr;
      expect(expr.op.type, TokenType.slash);
    });

    // -------------------------
    // Operator precedence
    // -------------------------

    test('multiplication has higher precedence than addition', () {
      // 1 + 2 * 3 should parse as (1 + (2 * 3))
      final expr = parse('1 + 2 * 3') as BinaryExpr;
      expect(expr.op.type, TokenType.plus); // root is +
      expect(expr.right, isA<BinaryExpr>());
      expect((expr.right as BinaryExpr).op.type, TokenType.star); // right child is *
    });

    test('division has higher precedence than subtraction', () {
      // 6 - 4 / 2 should parse as (6 - (4 / 2))
      final expr = parse('6 - 4 / 2') as BinaryExpr;
      expect(expr.op.type, TokenType.minus);
      expect((expr.right as BinaryExpr).op.type, TokenType.slash);
    });

    test('addition is left-associative', () {
      // 1 + 2 + 3 should parse as ((1 + 2) + 3)
      final expr = parse('1 + 2 + 3') as BinaryExpr;
      expect(expr.op.type, TokenType.plus);
      expect(expr.left, isA<BinaryExpr>()); // left child is (1 + 2)
    });

    // -------------------------
    // Parentheses
    // -------------------------

    test('parentheses override operator precedence', () {
      // (1 + 2) * 3: root must be *
      final expr = parse('(1 + 2) * 3') as BinaryExpr;
      expect(expr.op.type, TokenType.star); // root is *
      expect(expr.left, isA<BinaryExpr>());
      expect((expr.left as BinaryExpr).op.type, TokenType.plus);
    });

    test('parses nested parentheses', () {
      final expr = parse('((1 + 2))');
      expect(expr, isA<BinaryExpr>());
    });

    // -------------------------
    // Unary minus
    // -------------------------

    test('parses unary minus', () {
      final expr = parse('-3') as UnaryExpr;
      expect(expr.op.type, TokenType.minus);
      expect((expr.operand as NumberExpr).value, 3);
    });

    test('unary minus has higher precedence than multiplication', () {
      // -3 * 2 should parse as (-3) * 2
      final expr = parse('-3 * 2') as BinaryExpr;
      expect(expr.op.type, TokenType.star);
      expect(expr.left, isA<UnaryExpr>());
    });

    test('unary minus can be applied to a parenthesized expression', () {
      final expr = parse('-(1 + 2)') as UnaryExpr;
      expect(expr.operand, isA<BinaryExpr>());
    });

    test('consecutive unary minus operators are parsed correctly', () {
      // --3 should parse as -(-3)
      final expr = parse('--3') as UnaryExpr;
      expect(expr.operand, isA<UnaryExpr>());
    });

    // -------------------------
    // Error cases
    // -------------------------

    test('throws ParseException when closing parenthesis is missing', () {
      expect(() => parse('(1 + 2'), throwsA(isA<ParseException>()));
    });

    test('throws ParseException when right-hand side of operator is missing', () {
      expect(() => parse('1 +'), throwsA(isA<ParseException>()));
    });

    test('throws ParseException when two numbers appear consecutively', () {
      expect(() => parse('1 2'), throwsA(isA<ParseException>()));
    });

    test('throws ParseException for empty parentheses', () {
      expect(() => parse('()'), throwsA(isA<ParseException>()));
    });
  });
}
