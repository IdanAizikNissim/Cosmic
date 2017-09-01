import 'dart:mirrors';
import 'http_provider.dart';

import 'annotations/annotation.dart';
import 'annotations/client.dart';
import 'annotations/http_method.dart';
import 'annotations/http_methods.dart';
import 'service.dart';

class Parser {
  final List<String> _errors = new List();

  List<String> get errors => _errors;

  parse(Service service) {
    // Check if client is annotated with @Client
    final clientAnnotation = _getAnnotated(reflectClass(service.runtimeType), Client);
    if (clientAnnotation == null) {
      return null;
    } else {
      _bootstrapHttpMethods(clientAnnotation.path, service);

      return service;
    }
  }

  void _bootstrapHttpMethods(String path, service) {
    var im = reflect(service);
    var cm = im.type;

    // Get instance methods
    for (var declaration in cm.declarations.values) {
      final httpMethod = _isHttpMethod(declaration);
      if (httpMethod!= null) {
        final String methodName = MirrorSystem.getName(declaration.simpleName);
        service.add(methodName, HttpProvider.provide(httpMethod, path, declaration));
      }
    }
  }

  _isHttpMethod(declaration) {
    if (declaration is MethodMirror && declaration.isAbstract) {
      for (Type method in HttpMethods) {
        final httpMethodAnnotation = _getAnnotated(declaration, method);

        if (httpMethodAnnotation != null) return httpMethodAnnotation;
      }
    }

    return null;
  }

  // Returns the annotated prop
  dynamic _getAnnotated(DeclarationMirror dm, Type type) {
    final annotated = _getAnnotateds(dm, type);
    return annotated != null ? annotated.first : null;
  }


  // Returns the annotated props
  // if multiple annotated but marked as once return null
  List<dynamic> _getAnnotateds(DeclarationMirror dm, Type type) {
    Annotation annotation = _getAnnotationInstance(type);

    if (annotation == null) {
      _addError("${reflectType(type).qualifiedName} is invalid annotation");
      return null;
    }

    var annotations =
      dm.metadata.where((a) => a.reflectee.runtimeType == type).toList();

    if (annotations.length == 0) {
      return null;
    } else if (annotation.once && annotations.length > 1) {
       _addError("Annotation ${reflectType(type).qualifiedName} marked as once but multiple usages were found");
      return null;
    }

    return annotations.map((annotation) => annotation.reflectee).toList();
  }

  Annotation _getAnnotationInstance(Type type) {
    Annotation annotation;
    var typeMirror = reflectType(type);

    // Check if type is an Annotation
    if (!(typeMirror is ClassMirror)) {
       _addError("Type ${typeMirror.qualifiedName} is not a class");
    } else {
      final typeName = (typeMirror as ClassMirror).qualifiedName;

      // Client
      if (typeName == reflectType(Client).qualifiedName) {
        annotation = new Client("");
      }
      // HttpMethod
      else if ((typeMirror as ClassMirror).superclass != null &&
          (typeMirror as ClassMirror).superclass.qualifiedName == reflectType(HttpMethod).qualifiedName) {
        annotation = new HttpMethod("");
      }
    }

    return annotation;
  }

  void _addError(String error) {
    _errors.add(error);
  }
}
