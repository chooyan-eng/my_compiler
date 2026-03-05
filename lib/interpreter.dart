// lib/interpreter.dart

import 'package:my_compiler/let.dart';

import 'ast.dart'; // your sealed class definitions
import 'token.dart';

class InterpreterError implements Exception {
  final String message;
  InterpreterError(this.message);
  @override
  String toString() => 'InterpreterError: $message';
}

class Interpreter {
  // Entry point: evaluate a top-level expression
  double evaluate(Expr expr) => _evalExpr(expr);

  double _evalExpr(Expr expr) => switch (expr) {
        NumberExpr(:final value) => value,
        UnaryExpr(:final op, :final operand) => switch (op.type) {
            TokenType.minus => -_evalExpr(operand),
            _ => throw InterpreterError('Unknown unary operator: ${op.lexeme}'),
          },
        BinaryExpr(:final op, :final left, :final right) =>
          (l: _evalExpr(left), r: _evalExpr(right)).let(
            (val) => switch (op.type) {
              TokenType.plus => val.l + val.r,
              TokenType.minus => val.l - val.r,
              TokenType.star => val.l * val.r,
              TokenType.slash => val.r == 0
                  ? throw InterpreterError('Division by zero')
                  : val.l / val.r,
              _ =>
                throw InterpreterError('Unknown binary operator: ${op.lexeme}'),
            },
          )!,
      };
}
