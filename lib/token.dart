enum TokenType {
  // Literals
  number,

  // Operators
  plus, // +
  minus, // -
  star, // *
  slash, // /

  // Delimiters
  lparen, // (
  rparen, // )

  // sentences
  let, // let
  assign, // =
  semicolon, // ;
  identifier, // variable names

  // End of file
  eof,
}

class Token {
  final TokenType type;
  final String lexeme; // The original string in source code (e.g., "42")
  final int line; // Line number (for error reporting)
  final int column; // Column number (for error reporting)

  const Token({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.column,
  });

  @override
  String toString() => 'Token($type, "$lexeme", $line:$column)';
}
