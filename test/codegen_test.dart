import 'dart:io';

import 'package:my_compiler/compiler.dart';
import 'package:test/test.dart';

void main() {
  Future<int> compile(String source) async {
    await Compiler().compileToExecutable(source, './test_out');
    final result = await Process.run('./test_out', []);
    // Parse stdout instead of exitCode to avoid 8-bit truncation.
    return int.parse((result.stdout as String).trim());
  }

  group('X8664CodeGenerator', () {
    test('integer literal', () async => expect(await compile('7'), equals(7)));
    test('addition', () async => expect(await compile('3 + 4'), equals(7)));
    test('subtraction', () async => expect(await compile('10 - 3'), equals(7)));
    test('multiplication',
        () async => expect(await compile('2 * 4'), equals(8)));
    test('division', () async => expect(await compile('20 / 4'), equals(5)));
    test('operator precedence',
        () async => expect(await compile('1 + 2 * 3'), equals(7)));
    test('parentheses',
        () async => expect(await compile('(1 + 2) * 3'), equals(9)));
    test(
        'unary minus', () async => expect(await compile('10 + -3'), equals(7)));
    test('multiply', () async => expect(await compile('30 * 20'), equals(600)));
  });
}
