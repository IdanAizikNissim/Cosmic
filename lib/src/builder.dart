import 'package:build/build.dart';
import 'package:cosmic/src/builder_generator.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

Builder cosmicBuilder(BuilderOptions options) {
  return new LibraryBuilder(
    new ClientGenerator(),
    formatOutput: new DartFormatter().format,
  );
}