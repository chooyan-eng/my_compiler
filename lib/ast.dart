// lib/ast.dart

import 'package:my_compiler/token.dart';

sealed class Expr {}

/// 数値リテラル。例: 42
class NumberExpr extends Expr {
  final int value; // Phase A は整数のみ
  NumberExpr(this.value);
}

/// 二項演算。例: 1 + 2
class BinaryExpr extends Expr {
  final Token op; // 演算子トークンをそのまま持つ（行番号・列番号のため）
  final Expr left;
  final Expr right;
  BinaryExpr(this.op, this.left, this.right);
}

/// 単項マイナス。例: -3, -(1+2)
class UnaryExpr extends Expr {
  final Token op; // '-' トークン
  final Expr operand;
  UnaryExpr(this.op, this.operand);
}
