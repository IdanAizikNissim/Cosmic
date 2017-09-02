import 'dart:mirrors';

import 'package:cosmic/src/annotations/data.dart';
import 'package:cosmic/src/http_provider.dart';
import 'package:cosmic/src/service.dart';
import 'package:cosmic/src/utils.dart';

class Gen {
  static String generate(Service service) {
    List<String> methods = new List();
    service.values.forEach((sym, provider) {
      methods.add(
          _generateHttpMethod(getSymbolName(sym), provider)
      );
    });

    return _wrapWithClass(
      getSymbolName(reflectType(service.runtimeType).simpleName),
      methods
    );
  }

  static String _wrapWithClass(String serviceName, List<String> methods) {
    return '''
    import 'dart:async';
    import 'package:http/http.dart' as http;
    import 'package:jsonx/jsonx.dart';
    class $serviceName {
    ${methods.join('\n')}
    }
    ''';
  }

  static String _generateHttpMethod(String name, HttpProvider provider) {
    String httpM = _httpMethodType(provider.method.runtimeType);

    return '''
    Future<${_defineReturnType(provider.returns)}> $name(${_getWrapFuncParams(provider.pathParams, provider.queryParams, provider.headerMap, provider.body)}) {
      Type returnType = ${_defineReturnType(provider.returns, true)};\n
      ${_wrapRequest('''http.$httpM("${_getPath(provider.path, provider.pathParams, provider.queryParams)}"
      ${_addBodyIfExists(provider.body)}
      ${_addHeaderIfExists(provider.headerMap)})''')}
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
        return "const TypeHelper<$r>().type";
      }
    }
  }

  static String _wrapRequest(String req) {
    return '''
    var completer = new Completer();\n\n
    $req.then((response) {
      if (returnType == http.Response ||
          response.body == null) {
        completer.complete(response);
      } else {
        completer.complete(
            decode(response.body, type: returnType)
        );
      }
    });\n\n
    return completer.future;
    ''';
  }

  static _getWrapFuncParams(List<Path> pathParams, List<Query> queryParams, HeaderMap header, Body body) {
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

  static _addHeaderIfExists(HeaderMap headerMap) {
    return headerMap == null ? '' : ', headers: ${headerMap.name}';
  }

  static String _addBodyIfExists(Body body) {
    return body == null ? '' : ', body: encode(${body.name}),';
  }

  static String _getPath(String basePath, List<Path> pathParams, List<Query> queryParams) {
    for (var pathParam in pathParams) {
      basePath = basePath.replaceFirst("{${pathParam.param}}", "\$${pathParam.param}");
    }

    bool firstQP = true;
    for (var qParam in queryParams) {
      var sym = '&';
      if (firstQP) {
        var sym = '?';
        firstQP = false;
      }

      basePath = "$basePath$sym${qParam.query}=\$${qParam.query}";
    }

    return basePath;
  }

  static String _httpMethodType(Type type) {
    return getSymbolName(reflectType(type).simpleName).toLowerCase();
  }
}