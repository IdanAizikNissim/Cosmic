import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';

const ARG_OPTION_INPUT    = 'input';
const ARG_OPTION_OUTPUT   = 'output';
const ARG_FLAG_OVERWRITE  = 'overwrite';

main(List<String> arguments) async {
  var args = _parseArgs(arguments);

  var inputFilePath = absolute(args[ARG_OPTION_INPUT]);
  File inputFile = _getInputFile(inputFilePath);

  var outPutDir = absolute(args[ARG_OPTION_OUTPUT]);
  var outPutFilePath = "${outPutDir}/${basename(inputFilePath)}";

  // Get output file
  File outputFile = _getOutPutFile(outPutFilePath, args[ARG_FLAG_OVERWRITE]);

  // create output dir if not exists
  _createOutputDir(outPutDir);

  // Load input file
}

void _createOutputDir(String path) {
  new Directory(path).createSync(recursive: true);
}

File _getInputFile(String path) {
  var file = new File(path);
  if (!file.existsSync()) throw new Exception("${basename(path)} not exists");

  return file;
}

File _getOutPutFile(String path, bool overwrite) {
  var file = new File(path);

  if (file.existsSync() && !overwrite)
    throw new Exception("File ${path} exists but overwrite flag is of");

  return file;
}

ArgResults _parseArgs(List<String> args) {
  var parser = new ArgParser();
  parser.addOption(ARG_OPTION_INPUT, abbr: 'i');
  parser.addOption(ARG_OPTION_OUTPUT, abbr: 'o');
  parser.addFlag(ARG_FLAG_OVERWRITE, abbr: 'w', defaultsTo: false);

  return parser.parse(args);
}