// test/interpreter_test.dart

import 'package:my_compiler/interpreter.dart';
import 'package:my_compiler/lexer.dart';
import 'package:my_compiler/parser.dart';
import 'package:test/test.dart';

void main() {
  double eval(String source) {
    final tokens = Lexer(source).tokenize();
    final ast = Parser(tokens).parse();
    return Interpreter().evaluate(ast);
  }

  group('Interpreter - arithmetic', () {
    test('integer literal', () => expect(eval('42'), equals(42.0)));
    test('addition', () => expect(eval('1 + 2'), equals(3.0)));
    test('subtraction', () => expect(eval('5 - 3'), equals(2.0)));
    test('multiplication', () => expect(eval('4 * 3'), equals(12.0)));
    test('division', () => expect(eval('10 / 4'), equals(2.5)));
  });

  group('Interpreter - operator precedence', () {
    // Parser already encodes precedence in the AST,
    // so this validates the full pipeline end-to-end.
    test('2 + 3 * 4 == 14', () => expect(eval('2 + 3 * 4'), equals(14.0)));
    test('(2 + 3) * 4 == 20', () => expect(eval('(2 + 3) * 4'), equals(20.0)));
    test('10 - 2 - 3 == 5', () => expect(eval('10 - 2 - 3'), equals(5.0)));
  });

  group('Interpreter - unary', () {
    test('negation', () => expect(eval('-5'), equals(-5.0)));
    test('double negation', () => expect(eval('--5'), equals(5.0)));
    test('negation in expr', () => expect(eval('10 + -3'), equals(7.0)));
  });

  group('Interpreter - error handling', () {
    test('division by zero throws', () {
      expect(() => eval('1 / 0'), throwsA(isA<InterpreterError>()));
    });
  });
}
