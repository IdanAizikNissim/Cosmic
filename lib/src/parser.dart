import 'dart:mirrors';
import 'annotations/annotation.dart';
import 'annotations/client.dart';
import 'annotations/http_methods.dart';

class Parser {
  parse(Type c) {
    ClassMirror mirror = reflectClass(c);

    // Check if client is annotated with @Client
    final clientAnnotation = _getAnnotated(mirror, new Client.empty());
    if (clientAnnotation == null) {

    } else {
      // Get http methods
      final methods = [
        new Get(""),
        new Post(""),
        new Put(""),
        new Patch(""),
        new Delete(""),
        new Head("")
      ];

      methods.forEach((method) {
        final methodAnnotations = _getAnnotateds(mirror, method);
        print("");
      });
    }
  }

  // Returns the annotated prop
  dynamic _getAnnotated(DeclarationMirror dm, Annotation annotation) =>
      _getAnnotateds(dm, annotation).first;


  // Returns the annotated props
  // if multiple annotated but marked as once return null
  List<dynamic> _getAnnotateds(DeclarationMirror dm, Annotation annotation) {
    var annotations =
      dm.metadata.where((a) => a.reflectee.runtimeType == annotation).toList();

    if (annotations.length == 0) {
      return null;
    } else if (annotation.once && annotations.length > 1) {
      var name = MirrorSystem.getName(dm.simpleName);
//    addError('Multiple ${apiType} annotations on declaration \'$name\'.');
      return null;
    }

    return annotations.map((annotation) => annotation.reflectee);
  }
}
