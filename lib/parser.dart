// lib/parser.dart

import 'package:my_compiler/ast.dart';
import 'package:my_compiler/token.dart';

class ParseException implements Exception {
  final String message;
  final int line;
  final int column;

  ParseException(this.message, this.line, this.column);

  @override
  String toString() => 'ParseError at $line:$column → $message';
}

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  // Entry point
  Expr parse() {
    final expr = _expression();
    // After parsing, we must be at EOF
    if (!_isAtEnd()) {
      final t = _peek();
      throw ParseException(
        'Unexpected token "${t.lexeme}"',
        t.line,
        t.column,
      );
    }
    return expr;
  }

  // expression = term ( ( "+" | "-" ) term )* ;
  Expr _expression() {
    Expr left = _term();
    Token? op;
    while ((op = _match([TokenType.plus, TokenType.minus])) != null) {
      final right = _term();
      left = BinaryExpr(op!, left, right);
    }
    return left;
  }

  // term = unary ( ( "*" | "/" ) unary )* ;
  Expr _term() {
    Expr left = _unary();
    Token? op;
    while ((op = _match([TokenType.star, TokenType.slash])) != null) {
      final right = _unary();
      left = BinaryExpr(op!, left, right);
    }
    return left;
  }

  // unary = "-" unary | primary ;
  Expr _unary() {
    final op = _match([TokenType.minus]);
    if (op != null) {
      return UnaryExpr(op, _unary());
    }
    return _primary();
  }

  // primary = NUMBER | "(" expression ")" ;
  Expr _primary() {
    if (_check(TokenType.number)) {
      final token = _advance();
      return NumberExpr(int.parse(token.lexeme));
    }
    if (_check(TokenType.lparen)) {
      _advance(); // consume '('
      if (_check(TokenType.rparen)) {
        final t = _peek();
        throw ParseException('Expected expression inside parentheses', t.line, t.column);
      }
      final expr = _expression();
      _expect(TokenType.rparen, 'Expected ")" after expression');
      return expr;
    }
    final t = _peek();
    throw ParseException('Expected number or "(" but got "${t.lexeme}"', t.line, t.column);
  }

  // --- Helper methods ---

  /// Returns the current token without consuming it.
  Token _peek() => tokens[_current];

  /// Returns true if the current token is EOF.
  bool _isAtEnd() => _peek().type == TokenType.eof;

  /// Consumes and returns the current token.
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return tokens[_current - 1];
  }

  /// Returns true if the current token matches the given type.
  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  /// Consumes the current token if it matches any of the given types.
  /// Returns the consumed token, or null if no match.
  Token? _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) return _advance();
    }
    return null;
  }

  /// Consumes the current token if it matches the expected type.
  /// Throws ParseException if it does not match.
  Token _expect(TokenType type, String errorMessage) {
    if (_check(type)) return _advance();
    final t = _peek();
    throw ParseException(errorMessage, t.line, t.column);
  }
}
