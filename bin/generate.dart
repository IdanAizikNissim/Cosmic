import 'dart:io';

import 'package:cosmic/generateor.dart';
import 'package:dart_style/dart_style.dart';
import 'package:args/args.dart';
import 'package:path/path.dart';

const ARG_OPTION_INPUT         = 'input';
const ARG_OPTION_SERVICE_CLASS = 'class';
const ARG_OPTION_OUTPUT        = 'output';
const ARG_FLAG_OVERWRITE       = 'overwrite';

main(List<String> arguments) async {
  var args = _parseArgs(arguments);

  assert(args[ARG_OPTION_INPUT] != null);
  assert(args[ARG_OPTION_SERVICE_CLASS] != null);

  final String input = args[ARG_OPTION_INPUT];
  var inputFilePath = absolute(input);
  File inputFile = _getInputFile(inputFilePath);

  final output = (args[ARG_OPTION_OUTPUT] != null) ? 
    args[ARG_OPTION_OUTPUT] : 
    input.substring(0, input.lastIndexOf('/'));

  var outPutDir = absolute(output);
  var outPutFilePath = "${outPutDir}/${basename(inputFilePath.replaceFirst('.', '.g.'))}";

  // Get output file
  File outputFile = _getOutPutFile(outPutFilePath, args[ARG_FLAG_OVERWRITE]);

  // create output dir if not exists
  _createOutputDir(outPutDir);

  // Get generated code
  var generated = await generate(toUri(absolute(inputFile.path)), args[ARG_OPTION_SERVICE_CLASS], output, input.substring(input.lastIndexOf('/') + 1, input.lastIndexOf('.')));
  outputFile.openWrite();
  outputFile.writeAsString(new DartFormatter().format(generated.toString()));
}

void _createOutputDir(String path) {
  new Directory(path).createSync(recursive: true);
}

File _getInputFile(String path) {
  var file = new File(path);
  if (!file.existsSync()) throw new Exception("${basename(path)} not exists");

  return file;
}

File _getOutPutFile(String path, [bool overwrite = false]) {
  var file = new File(path);

  if (file.existsSync() && !overwrite)
    throw new Exception("File ${path} exists but overwrite flag is off");

  return file;
}

ArgResults _parseArgs(List<String> args) {
  var parser = new ArgParser();
  parser.addOption(ARG_OPTION_INPUT, abbr: 'i');
  parser.addOption(ARG_OPTION_SERVICE_CLASS, abbr: 'c');
  parser.addOption(ARG_OPTION_OUTPUT, abbr: 'o');
  parser.addFlag(ARG_FLAG_OVERWRITE, abbr: 'w', defaultsTo: false);

  return parser.parse(args);
}