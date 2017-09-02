import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:path/path.dart';

const ARG_OPTION_INPUT         = 'input';
const ARG_OPTION_SERVICE_CLASS = 'class';
const ARG_OPTION_OUTPUT        = 'output';
const ARG_FLAG_OVERWRITE       = 'overwrite';

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

  // Get generated code
  var generated = await _generate(toUri(absolute(inputFile.path)), args[ARG_OPTION_SERVICE_CLASS]);
  outputFile.openWrite();
  outputFile.writeAsString(generated.toString());
}

Future<List<String>> _generate(Uri path, String serviceClass) async {
  return _withServer(path.toString(), (HttpServer server) async {
    return await _execute(server.port, path, serviceClass);
  });
}

Future<dynamic> _execute(int port, Uri path, String serviceClass) async {
  ReceivePort messagePort = new ReceivePort();
  ReceivePort errorPort = new ReceivePort();

  closePorts() {
    messagePort.close();
    errorPort.close();
  }

  try {
    await Isolate.spawn(
        _isolateLoader,
        [
          "http://127.0.0.1:$port",
          messagePort.sendPort,
          errorPort.sendPort,
          serviceClass
        ],
        onError: errorPort.sendPort
    );
  } catch (error) {
    closePorts();
    rethrow;
  }

  var completer = new Completer();
  var messageSubscription;
  var errorSubscription;

  finish(value, isError) {
    messageSubscription.cancel();
    errorSubscription.cancel();
    closePorts();
    if (isError) {
      completer.completeError(value);
    } else {
      completer.complete(value);
    }
  }

  messageSubscription = messagePort.listen((value) {
    finish(value, false);
  });

  errorSubscription = errorPort.listen((error) {
    finish(error, true);
  });

  return completer.future;
}

Future _isolateLoader(List args) async {
  return Isolate.spawnUri(
      Uri.parse(args[0]), // service.dart
      [args[3]], // ServiceClassName
      args[1] as SendPort,
      onError: args[2] as SendPort
  );
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
  parser.addOption(ARG_OPTION_SERVICE_CLASS, abbr: 'c');
  parser.addOption(ARG_OPTION_OUTPUT, abbr: 'o');
  parser.addFlag(ARG_FLAG_OVERWRITE, abbr: 'w', defaultsTo: false);

  return parser.parse(args);
}

_withServer(String apiFilePath, f(HttpServer server)) async {
  Future _httpSourceLoader(HttpRequest request) async {
    var path = request.uri.path;
    if (path.contains('/packages/')) {
      File packageFile = new File(findPackageRoot(apiFilePath) + path);
      request.response
        ..add(packageFile.readAsBytesSync())
        ..close();
    } else if (path.contains('.packages')) {
      // Didn't find .packages so revert to /packages/.
      request.response
        ..statusCode = HttpStatus.NOT_FOUND
        ..close();
    } else {
      request.response
        ..add(UTF8.encode(_generatorSource(apiFilePath)))
        ..close();
    }
  }

  var server = await HttpServer.bind('127.0.0.1', 0);
  try {
    server.listen(_httpSourceLoader);
    return await f(server);
  } finally {
    server.close();
  }
}

String _generatorSource(String apiFilePath) {
  return '''
  import 'dart:mirrors';
  import 'package:cosmic/cosmic.dart';
  import '${apiFilePath}';
  
  main(args, message) async {
    MirrorSystem mirrors = currentMirrorSystem();
    var lm;
    mirrors.libraries.forEach((key, val) {
      if (key == Uri.parse('${apiFilePath}')) {
        lm = val;
        return;
      }
    });
    
    if (lm == null) {
      message.send("lib '${apiFilePath}' didn't load");
    } else {
      ClassMirror cm = lm.declarations[new Symbol(args[0])];
      if (cm == null) {
        message.send("service args[0] isn't definded in '${apiFilePath}'");
      } else {
        var im = cm.newInstance(new Symbol(''), []);
        message.send(Cosmic.generate(im.reflectee));
      }
    }
  }
  ''';
}

String findPackageRoot(String path) {
  if (path == null) {
    return null;
  }
  if (path.startsWith('file:')) {
    path = fromUri(path);
  }
  path = absolute(path);
  while (path != dirname(path)) {
    // We use the pubspec.yaml file as an indicator of being in the package
    // root directory.
    File pubspec = new File(join(path, 'pubspec.yaml'));
    if (pubspec.existsSync()) return path;
    path = dirname(path);
  }
  return null;
}
