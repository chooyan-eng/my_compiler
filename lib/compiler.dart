import 'dart:io';

import 'package:my_compiler/codegen/x86_64_codegen.dart';
import 'package:my_compiler/lexer.dart';
import 'package:my_compiler/parser.dart';

class Compiler {
  Future<void> compileToExecutable(String source, String outPath) async {
    // 1. Lex
    final tokens = Lexer(source).tokenize();
    // 2. Parse
    final ast = Parser(tokens).parse();
    // 3. Generate assembly
    final asm = X8664CodeGenerator().generate(ast);

    // 4. Write assembly file into a unique temp directory to avoid conflicts
    //    when multiple tests run concurrently.
    final tempDir = Directory.systemTemp.createTempSync('my_compiler_');
    try {
      final asmPath = '${tempDir.path}/out.s';
      final objPath = '${tempDir.path}/out.o';

      await File(asmPath).writeAsString(asm);

      // 5. Assemble with NASM
      final nasmResult = await Process.run('nasm', [
        '-f',
        'macho64',
        asmPath,
        '-o',
        objPath,
      ]);
      if (nasmResult.exitCode != 0) {
        throw Exception('NASM failed:\n${nasmResult.stderr}');
      }

      // 6. Link with ld
      final ldResult = await Process.run('ld', [
        objPath,
        '-o',
        outPath,
        '-macosx_version_min',
        '10.13',
        '-e',
        '_main',
        '-arch',
        'x86_64',
        '-lSystem',
        '-L',
        '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib',
      ]);
      if (ldResult.exitCode != 0) {
        throw Exception('ld failed:\n${ldResult.stderr}');
      }
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  }
}
