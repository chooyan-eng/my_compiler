import 'dart:io';

import 'package:my_compiler/compiler.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run bin/main.dart <source_file> [output_file]');
    exit(1);
  }

  final sourceFile = File(args[0]);

  if (!sourceFile.existsSync()) {
    stderr.writeln('Error: file not found: ${args[0]}');
    exit(1);
  }

  // Default output path: strip extension and use filename as binary name.
  // e.g. "program.src" → "./program"
  final outPath = args.length >= 2
      ? args[1]
      : './${sourceFile.uri.pathSegments.last.split('.').first}';

  final source = await sourceFile.readAsString();

  try {
    await Compiler().compileToExecutable(source, outPath);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
