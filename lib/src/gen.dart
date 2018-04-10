part of cosmic;

class Gen {
  static String generate(Client client, String filename, List<String> imports, String outputPath) {
    List<String> methods = new List();
    client.values.forEach((sym, provider) {
      methods.add(
        _generateHttpMethod(getSymbolName(sym), provider.method.path, provider)
      );
    });

    final provider = client.values.values.toList().first;

    return _wrapWithClass(
      filename,
      getSymbolName(reflectType(client.runtimeType).simpleName),
      imports,
      outputPath,
      provider.converterName,
      provider.converterPackage,
      methods,
      provider.path
    );
  }

  static String _wrapWithClass(
    String filename,
    String serviceName,
    List<String> imports,
    String outputPath,
    String converterName,
    String converterPackage,
    List<String> methods,
    String url
  ) {
    return '''  
    part of '$filename.dart';
    abstract class _\$$serviceName {
    final url = "$url";
    final converter = const $converterName();\n
    ${methods.join('\n')}
    \n
    ${_requestWrapperMethod()}\n
    ${_callMiddlewaresMethod()}\n
    List<Cosmic.Middleware> getMiddlewares(String path);
    }
    ''';
  }

  static String _generateHttpMethod(String name, String path, HttpProvider provider) {
    String httpM = _httpMethodType(provider.method.runtimeType);
    final definedReturnType = _defineReturnType(provider.returns);
    return '''
    Future<$definedReturnType> $name(${_getWrapFuncParams(provider.pathParams, provider.queryParams, provider.headerMap, provider.body)}) {
      final Type returnType = ${_defineReturnType(provider.returns, true)};
      final String path = "$path";\n
      return _callMiddleware(
        new Cosmic.Request(
          "${_getPath(provider.method.path, provider.pathParams, provider.queryParams)}", 
          http.$httpM, 
          ${provider.method.runtimeType.toString()},
          ${_addBodyIfExists(provider.body)}
          ${_addHeaderIfExists(provider.headerMap)}
        ),
        returnType,
        path
      ).then<$definedReturnType>((results) => results);
    }
    ''';
  }

  static String _defineReturnType(Type returns, [bool genericWrap = false]) {
    var rType = reflectType(returns);
    var args = rType.typeArguments;

    if (args.length == 0) {
      var name = getSymbolName(rType.simpleName);

      if (name == "Response") {
        return "http.$name";
      }

      return name;
    } else {
      var r = "${getSymbolName(rType.simpleName)}<${getSymbolName(args.first.simpleName)}>";

      if (!genericWrap) {
        return r;
      } else {
        return "const Cosmic.TypeProvider<$r>().type";
      }
    }
  }

  static String _requestWrapperMethod() {
    return '''
    Future<dynamic> _request(Future<http.Response> req, Type returnType) {
      var completer = new Completer();
  
      req.then((response) {
        if (returnType == http.Response) {
          completer.complete(response);
        } else if (response.body == null) {
          completer.completeError(response);
        } else {
          completer.complete(
            converter.decode(response.body, type: returnType)
          );
        }
      }).catchError((error) => completer.completeError(error));
  
      return completer.future;
    }
    ''';
  }

  static String _callMiddlewaresMethod() {
    return '''
    Future<dynamic> _callMiddleware(Cosmic.Request request, Type returnType, String path, {int index = 0, Completer completer, List<Cosmic.Middleware> reqMiddlewares}) async {
      reqMiddlewares = reqMiddlewares?? getMiddlewares(path);
      completer = completer?? new Completer();
  
      if (index >= reqMiddlewares.length) {
        completer.complete(await _request(request.bind(), returnType));
      } else {
        reqMiddlewares[index](request, () {
          _callMiddleware(request, returnType, path, index: index + 1, completer: completer, reqMiddlewares: reqMiddlewares);
        });
      }
  
      return completer.future;
    }
    ''';
  }

  static _getWrapFuncParams(List<ANTN.Path> pathParams, List<ANTN.Query> queryParams, ANTN.HeaderMap header, ANTN.Body body) {
    List<String> params = pathParams.map((p) => "${p.type} ${p.param}").toList();
    params.addAll(queryParams.map((q) => "${q.type} ${q.query}").toList());

    if (header != null) {
      params.add("${header.type} ${header.name}");
    }

    if (body != null) {
      params.add("${body.type} ${body.name}");
    }

    return params.length == 0 ? "" : "{${params.join(",")}}";
  }

  static _addHeaderIfExists(ANTN.HeaderMap headerMap) {
    return headerMap == null ? '' : 'headers: ${headerMap.name}';
  }

  static String _addBodyIfExists(ANTN.Body body) {
    return body == null ? '' : 'body: converter.encode(${body.name}),';
  }

  static String _getPath(String methodPath, List<ANTN.Path> pathParams, List<ANTN.Query> queryParams) {
    for (var pathParam in pathParams) {
      methodPath = methodPath.replaceFirst("{${pathParam.param}}", "\$${pathParam.param}");
    }

    bool firstQP = true;
    for (var qParam in queryParams) {
      var sym = '&';
      if (firstQP) {
        sym = '?';
        firstQP = false;
      }

      methodPath = "$methodPath$sym${qParam.query}=\$${qParam.query}";
    }

    return "\$url$methodPath";
  }

  static String _httpMethodType(Type type) {
    return getSymbolName(reflectType(type).simpleName).toLowerCase();
  }
}