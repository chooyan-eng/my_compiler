import 'token.dart';

class LexerException implements Exception {
  final String message;
  final int line;
  final int column;

  LexerException(this.message, this.line, this.column);

  @override
  String toString() => 'LexerError at $line:$column → $message';
}

class Lexer {
  final String source;
  int _start = 0;
  int _current = 0;
  int _line = 1;
  int _column = 1;

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _start = _current;
      final token = _scanToken();
      if (token != null) tokens.add(token);
    }

    tokens.add(Token(
      type: TokenType.eof,
      lexeme: '',
      line: _line,
      column: _column,
    ));

    return tokens;
  }

  // Returns true when the cursor has reached the end of source.
  bool _isAtEnd() => _current >= source.length;

  // Reads the current character, advances the cursor, and returns it.
  String _advance() {
    final char = source[_current];
    _current++;
    _column++;
    return char;
  }

  // Returns the substring from _start to _current as a character (peek at current without consuming).
  String _peek() => source[_current];

  // Creates a Token using the substring from _start to _current.
  Token _makeToken(TokenType type) {
    final lexeme = source.substring(_start, _current);
    // Column points to where this token started, not where it ended.
    final startColumn = _column - (_current - _start);
    return Token(
      type: type,
      lexeme: lexeme,
      line: _line,
      column: startColumn,
    );
  }

  // Scans the next token from the source string.
  // Returns null for whitespace (which is skipped).
  Token? _scanToken() {
    final char = _advance();

    switch (char) {
      case '+': return _makeToken(TokenType.plus);
      case '-': return _makeToken(TokenType.minus);
      case '*': return _makeToken(TokenType.star);
      case '/': return _makeToken(TokenType.slash);
      case '(': return _makeToken(TokenType.lparen);
      case ')': return _makeToken(TokenType.rparen);

      // Skip whitespace — return null so tokenize() doesn't add it.
      case ' ':
      case '\t':
      case '\r':
        return null;
      case '\n':
        _line++;
        _column = 1;
        return null;

      default:
        // Multi-digit number: consume consecutive digits.
        if (_isDigit(char)) {
          while (!_isAtEnd() && _isDigit(_peek())) {
            _advance();
          }
          return _makeToken(TokenType.number);
        }

        throw LexerException(
          'Unexpected character: "$char"',
          _line,
          _column - 1,
        );
    }
  }

  // Returns true if the character is an ASCII digit (0-9).
  bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
}
