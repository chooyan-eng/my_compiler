// lib/ast.dart

import 'package:my_compiler/token.dart';

sealed class Expr {}

/// A numeric literal. e.g. 42
class NumberExpr extends Expr {
  final int value; // Phase A: integers only
  NumberExpr(this.value);
}

/// A binary operation. e.g. 1 + 2
class BinaryExpr extends Expr {
  final Token op; // operator token retained for line/column info
  final Expr left;
  final Expr right;
  BinaryExpr(this.op, this.left, this.right);
}

/// A unary negation. e.g. -3, -(1+2)
class UnaryExpr extends Expr {
  final Token op; // the '-' token
  final Expr operand;
  UnaryExpr(this.op, this.operand);
}
