import 'package:my_compiler/ast.dart';
import 'package:my_compiler/codegen/codegen_interface.dart';
import 'package:my_compiler/token.dart';

class X8664CodeGenerator implements CodeGenerator {
  final _buf = StringBuffer();

  @override
  String generate(Expr expr) {
    _emitPrologue();
    _emitExpr(expr);
    _emitEpilogue();
    return _buf.toString();
  }

  // --- section emitters ---

  void _emitPrologue() {
    _buf.writeln('global _main');
    _buf.writeln();
    _buf.writeln('section .text');
    _buf.writeln('_main:');
  }

  void _emitEpilogue() {
    // At this point, rax holds the result of the expression.
    // Convert rax to a decimal string and write it to stdout,
    // then exit with code 0.
    //
    // NOTE: digit_loop uses unsigned div (div rbx), not idiv.
    // This means negative results will produce incorrect output.
    // Negative number support requires a sign check before the loop.
    // This will be replaced when print() is implemented as a language built-in.
    _buf.writeln('    sub rsp, 24');
    _buf.writeln('    lea rdi, [rsp + 21]');
    _buf.writeln('    mov byte [rdi], 10'); // trailing newline
    _buf.writeln('    dec rdi');
    _buf.writeln('    mov rbx, 10');
    _buf.writeln('.digit_loop:');
    _buf.writeln('    xor rdx, rdx');
    _buf.writeln('    div rbx'); // rax = quotient, rdx = remainder (digit)
    _buf.writeln('    add dl, 48'); // '0' + digit
    _buf.writeln('    mov [rdi], dl');
    _buf.writeln('    dec rdi');
    _buf.writeln('    test rax, rax');
    _buf.writeln('    jnz .digit_loop');
    _buf.writeln('    inc rdi'); // rdi = ptr to first digit
    _buf.writeln('    lea rcx, [rsp + 22]');
    _buf.writeln('    sub rcx, rdi'); // rcx = byte count (digits + newline)
    _buf.writeln('    mov rdx, rcx'); // arg3: length
    _buf.writeln('    mov rsi, rdi'); // arg2: buffer ptr
    _buf.writeln('    mov rdi, 1'); // arg1: stdout fd
    _buf.writeln('    mov rax, 0x2000004'); // write syscall
    _buf.writeln('    syscall');
    _buf.writeln('    add rsp, 24');
    _buf.writeln('    xor rdi, rdi');
    _buf.writeln('    mov rax, 0x2000001'); // exit(0)
    _buf.writeln('    syscall');
  }

  // --- expression emitters ---

  void _emitExpr(Expr expr) {
    switch (expr) {
      case NumberExpr(:final value):
        // Load the integer value directly into rax.
        // Truncate to int since x86_64 registers hold integers.
        final intVal = value.truncate();
        _buf.writeln('    mov rax, $intVal');

      case UnaryExpr(:final op, :final operand):
        _emitExpr(operand); // result in rax
        switch (op.type) {
          case TokenType.minus:
            _buf.writeln('    neg rax'); // rax = -rax
          default:
            throw CodegenError('Unsupported unary operator: ${op.lexeme}');
        }

      case BinaryExpr(:final op, :final left, :final right):
        // Stack-machine pattern:
        //   1. evaluate left  → result in rax
        //   2. push rax       → save left on stack
        //   3. evaluate right → result in rax
        //   4. pop rbx        → restore left into rbx
        //   5. apply operator → result in rax
        _emitExpr(left);
        _buf.writeln('    push rax');
        _emitExpr(right);
        _buf.writeln('    pop rbx');

        switch (op.type) {
          case TokenType.plus:
            _buf.writeln('    add rax, rbx'); // rax = rbx + rax
          case TokenType.minus:
            // Subtraction is not commutative: result = left - right = rbx - rax
            _buf.writeln('    sub rbx, rax');
            _buf.writeln('    mov rax, rbx');
          case TokenType.star:
            _buf.writeln('    imul rax, rbx'); // rax = rax * rbx
          case TokenType.slash:
            // idiv divides rdx:rax by the operand.
            // Dividend must be in rax, sign-extended into rdx.
            // Divisor goes in rbx. Quotient → rax, remainder → rdx.
            _buf.writeln('    xchg rax, rbx'); // rax = left, rbx = right
            _buf.writeln('    cqo'); // sign-extend rax into rdx:rax
            _buf.writeln('    idiv rbx'); // rax = rax / rbx
          default:
            throw CodegenError('Unsupported binary operator: ${op.lexeme}');
        }
    }
  }
}

class CodegenError implements Exception {
  final String message;
  CodegenError(this.message);
  @override
  String toString() => 'CodegenError: $message';
}
