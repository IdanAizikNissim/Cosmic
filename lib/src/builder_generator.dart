import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'dart:async';
import 'package:cosmic/annotations/cosmic_annotations.dart';
import 'package:path/path.dart';
import 'package:source_gen/source_gen.dart';
import 'package:cosmic/generateor.dart';

class ClientGenerator extends GeneratorForAnnotation<Client> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    // Get .dart file path
    final String absPath = toUri(absolute("")).toString();
    final String lastDir = "${absPath.substring(absPath.lastIndexOf("/") + 1, absPath.length)}/";
    String file = element.location.components[0];
    file = file.substring(file.indexOf(lastDir) + lastDir.length, file.length);

    // Get clien class name
    final String className = element.location.components[element.location.components.length - 1];
    
    return await generate(
      toUri(absolute(file)), 
      className, 
      file.substring(0, file.lastIndexOf('/'))
    );
  }
}