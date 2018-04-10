import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:isolate';

import 'package:path/path.dart';

Future<String> generate(Uri path, String serviceClass, String outputPath, String filename) async {
  return _withServer(path.toString(), (HttpServer server) async {
    return await _execute(server.port, path, serviceClass, outputPath, filename);
  });
}

Future<dynamic> _execute(int port, Uri path, String serviceClass, String outputPath, String filename) async {
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
          serviceClass,
          outputPath,
          filename,
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
      Uri.parse(args[0]), // client.dart
      [args[3], args[4], args[5]], // ServiceClassName
      args[1] as SendPort,
      onError: args[2] as SendPort,
  );
}

_withServer(String apiFilePath, f(HttpServer server)) async {
  Future _httpSourceLoader(HttpRequest request) async {
    var path = request.uri.path;
    if (path.contains('/packages/')) {
      File packageFile = new File(_findPackageRoot(apiFilePath) + path);
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
        ..add(new Utf8Encoder().convert(_generatorSource(apiFilePath)))
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
    List<String> toImport = new List();
    mirrors.libraries.forEach((key, val) {
      if (key == Uri.parse('${apiFilePath}')) {
        lm = val;
        return;
      } else if (key.toString().startsWith('file://')) {
        toImport.add(key);
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
        message.send(Cosmic.generate(im.reflectee, args[2], toImport, args[1]));
      }
    }
  }
  ''';
}

String _findPackageRoot(String path) {
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
