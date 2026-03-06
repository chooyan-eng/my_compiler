import 'dart:io';

import 'package:my_compiler/compiler.dart';
import 'package:test/test.dart';

void main() {
  Future<int> compile(String source) async {
    // Use a unique path in the system temp directory so concurrent tests do
    // not race on the same output file.  compileToExecutable derives its
    // intermediate file paths (*.s, *.o) from this path, so they also land
    // in a neutral location that is always writable.
    final tempDir = Directory.systemTemp.createTempSync('codegen_test_');
    final outPath = '${tempDir.path}/out';
    try {
      await Compiler().compileToExecutable(source, outPath);
      final result = await Process.run(outPath, []);
      // Parse stdout instead of exitCode to avoid 8-bit truncation.
      return int.parse((result.stdout as String).trim());
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  }

  group(
    'X8664CodeGenerator',
    () {
      test('integer literal',
          () async => expect(await compile('7'), equals(7)));
      test('addition',
          () async => expect(await compile('3 + 4'), equals(7)));
      test('subtraction',
          () async => expect(await compile('10 - 3'), equals(7)));
      test('multiplication',
          () async => expect(await compile('2 * 4'), equals(8)));
      test('division',
          () async => expect(await compile('20 / 4'), equals(5)));
      test('operator precedence',
          () async => expect(await compile('1 + 2 * 3'), equals(7)));
      test('parentheses',
          () async => expect(await compile('(1 + 2) * 3'), equals(9)));
      test('unary minus',
          () async => expect(await compile('10 + -3'), equals(7)));
      test('multiply',
          () async => expect(await compile('30 * 20'), equals(600)));
    },
    // This compiler emits x86-64 Mach-O binaries via NASM (macho64 format),
    // which only works on macOS.  Skip on all other platforms so that CI
    // runners on Linux do not fail with a missing-executable error.
    skip: Platform.isMacOS ? false : 'macOS only (requires nasm + Mach-O)',
  );
}
