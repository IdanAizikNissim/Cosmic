part of cosmic;

class Gen {
  static String generate(Client client, List<String> imports, String outputPath) {
    List<String> methods = new List();
    client.values.forEach((sym, provider) {
      methods.add(
        _generateHttpMethod(getSymbolName(sym), provider.method.path, provider)
      );
    });

    final provider = client.values.values.toList().first;

    return _wrapWithClass(
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
    String serviceName,
    List<String> imports,
    String outputPath,
    String converterName,
    String converterPackage,
    List<String> methods,
    String url
  ) {
    return '''
    import 'dart:async';
    import 'package:http/http.dart' as http;
    import 'package:cosmic/cosmic_lib.dart' show Client, Request, TypeProvider, Middleware;
    import 'package:cosmic/annotations/cosmic_annotations.dart' as ANTN;
    import 'package:${converterPackage != null ? "$converterPackage'" : "cosmic/converters/cosmic_converters.dart' show $converterName"};
    ${imports.map((import) => "import '${path.relative((import as Uri).path, from: outputPath)}';").toList().join()}
    class $serviceName extends Client {
    final url = "$url";
    final converter = const $converterName();\n
    ${methods.join('\n')}
    \n
    ${_requestWrapperMethod()}\n
    ${_callMiddlewaresMethod()}
    }
    ''';
  }

  static String _generateHttpMethod(String name, String path, HttpProvider provider) {
    String httpM = _httpMethodType(provider.method.runtimeType);

    return '''
    Future<${_defineReturnType(provider.returns)}> $name(${_getWrapFuncParams(provider.pathParams, provider.queryParams, provider.headerMap, provider.body)}) {
      final Type returnType = ${_defineReturnType(provider.returns, true)};
      final String path = "$path";\n
      return _callMiddleware(
        new Request(
          "${_getPath(provider.method.path, provider.pathParams, provider.queryParams)}", 
          http.$httpM, 
          ANTN.${provider.method.runtimeType.toString()},
          ${_addBodyIfExists(provider.body)}
          ${_addHeaderIfExists(provider.headerMap)}
        ),
        returnType,
        path
      );
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
        return "const TypeProvider<$r>().type";
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
    Future<dynamic> _callMiddleware(Request request, Type returnType, String path, {int index = 0, Completer completer, List<Middleware> reqMiddlewares}) async {
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
    List<String> params = pathParams.map((p) => p.param).toList();
    params.addAll(queryParams.map((q) => q.query).toList());

    if (header != null) {
      params.add(header.name);
    }

    if (body != null) {
      params.add(body.name);
    }

    return params.join(",");
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
        var sym = '?';
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