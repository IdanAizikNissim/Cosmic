part of cosmic;

class Parser {
  final List<String> _errors = new List();

  List<String> get errors => _errors;

  parse(Client client) {
    // Check if client is annotated with @Client
    final clientAnnotation = _getAnnotated(reflectClass(client.runtimeType), ANTN.Client);
    if (clientAnnotation == null) {
      return null;
    } else {
      final converterClassMirror = reflect(clientAnnotation.converter).type;
      final converterName = getSymbolName(converterClassMirror.simpleName);
      final converterPackage = converterClassMirror.location.sourceUri.path;

      _bootstrapHttpMethods(
        clientAnnotation.path,
        clientAnnotation.converter,
        converterName,
        !isCosmicConverter(converterPackage) ? converterPackage : null,
        client
      );

      return client;
    }
  }

  void _bootstrapHttpMethods(
    String path, Converter converter, String converterName, String converterPackage, Client client
  ) {
    var im = reflect(client);
    var cm = im.type;

    // Get instance methods
    for (var declaration in cm.declarations.values) {
      final httpMethod = _isHttpMethod(declaration);
      if (httpMethod!= null) {
        final String methodName =
          MirrorSystem.getName(declaration.simpleName);

        List<ParameterMirror> params = (declaration as MethodMirror).parameters;

        // Url param
        var url = _getDataAnnotatedParams(params, ANTN.Url);

        // Body param
        var body = _getDataAnnotatedParams(params, ANTN.Body);

        // HeaderMap
        var headerMap = _getDataAnnotatedParams(params, ANTN.HeaderMap);

        // Get return type
        List<TypeMirror> returns = (declaration as MethodMirror).returnType.typeArguments;

        client.add(
          methodName,
          new HttpProvider(
            httpMethod,
            path,
            _getDataAnnotatedParams(params, ANTN.Path),
            _getDataAnnotatedParams(params, ANTN.Query),
            headerMap.length != 0 ? headerMap.first : null,
            body.length != 0 ? body.first : null,
            url.length != 0 ? url.first : null,
            returns.length != 0 ? returns.first.reflectedType : null,
            converter,
            converterName,
            converterPackage,
            client.getMiddlewares(httpMethod.path)
          )
        );
      }
    }
  }

  _getDataAnnotatedParams(List<ParameterMirror> methodParams, Type type) {
    List<dynamic> params = new List();

    for (ParameterMirror param in methodParams) {
      List<dynamic> ps = _getAnnotateds(param, type);

      if (ps != null) {
        final String type = getSymbolName(param.type.simpleName);

        params.addAll(
          ps.map((p) => p.clone(type)).toList()
        );
      }
    }

    return params;
  }

  _isHttpMethod(declaration) {
    if (declaration is MethodMirror && declaration.isAbstract) {
      for (Type method in ANTN.HttpMethods) {
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
    ANTN.Annotation annotation = _getAnnotationInstance(type);

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

  ANTN.Annotation _getAnnotationInstance(Type type) {
    ANTN.Annotation annotation;
    var typeMirror = reflectType(type);

    // Check if type is an Annotation
    if (!(typeMirror is ClassMirror)) {
       _addError("Type ${typeMirror.qualifiedName} is not a class");
    } else {
      final typeName = (typeMirror as ClassMirror).qualifiedName;

      // Client
      if (typeName == reflectType(ANTN.Client).qualifiedName) {
        annotation = new ANTN.Client(path: "", converter: null);
      }
      // HttpMethod
      else if ((typeMirror as ClassMirror).superclass != null &&
          (typeMirror as ClassMirror).superclass.qualifiedName == reflectType(ANTN.HttpMethod).qualifiedName) {
        annotation = new ANTN.HttpMethod("");
      }
      // Path
      else if (typeName == reflectType(ANTN.Path).qualifiedName) {
        annotation = new ANTN.Path("");
      }
      // Query
      else if (typeName == reflectType(ANTN.Query).qualifiedName) {
        annotation = new ANTN.Query("");
      }
      // Url
      else if (typeName == reflectType(ANTN.Url).qualifiedName) {
        annotation = new ANTN.Url("");
      }
      // Body
      else if (typeName == reflectType(ANTN.Body).qualifiedName) {
        annotation = new ANTN.Body("");
      }
      // HeaderMap
      else if (typeName == reflectType(ANTN.HeaderMap).qualifiedName) {
        annotation = new ANTN.HeaderMap("");
      }
    }

    return annotation;
  }

  void _addError(String error) {
    _errors.add(error);
  }
}
