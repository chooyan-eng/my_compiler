import 'package:my_compiler/ast.dart';

abstract class CodeGenerator {
  // Receives the root AST node, returns a complete assembly source string.
  String generate(Expr expr);
}
