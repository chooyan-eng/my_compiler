enum TokenType {
  // リテラル
  number,

  // 演算子
  plus,   // +
  minus,  // -
  star,   // *
  slash,  // /

  // 区切り文字
  lparen, // (
  rparen, // )

  // 終端
  eof,
}

class Token {
  final TokenType type;
  final String lexeme;   // ソースコード上の元の文字列（"42"など）
  final int line;        // 行番号（エラー報告用）
  final int column;      // 列番号（エラー報告用）

  const Token({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.column,
  });

  @override
  String toString() => 'Token($type, "$lexeme", $line:$column)';
}
