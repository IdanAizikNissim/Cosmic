import 'dart:async';
import 'dart:mirrors';

import 'package:http/http.dart' as http;
import 'package:jsonx/jsonx.dart';

import 'annotations/http_method.dart';
import 'annotations/http_methods.dart';
import 'annotations/data.dart';

class HttpProvider {
  HttpMethod _method;
  String _path;
  List<Path> _pathParams;
  List<Query> _queryParams;
  Body _body;
  Url _url;
  TypeMirror _returns;

  HttpProvider(this._method, path, [
    this._pathParams,
    this._queryParams,
    this._body,
    this._url,
    this._returns
  ]) {
    this._path = _getPath(path, _method, url: _url);
  }

  call(Map<Symbol, dynamic> namedArguments) {
    _injectPathParams(namedArguments);
    _concatQueryParams(namedArguments);
    var body = _body != null ? _getBodyParam(namedArguments) : null;

    switch (this._method.runtimeType) {
      case Get:
        return _get();
      case Post:
        return _post(body);
      case Put:
      case Patch:
        return _put(body);
    }
  }

  String _getPath(String path, httpMethod, {
    Url url
  }) {
    return url != null ? url.url : "${path}${httpMethod.path}";
  }

  bool _isPathParam(String name) {
    for (Path p in _pathParams) {
      if (p.param == name) return true;
    }

    return false;
  }

  bool _isQueryParam(String name) {
    for (Query q in _queryParams) {
      if (q.query == name) return true;
    }

    return false;
  }

  void _injectPathParams(Map<Symbol, dynamic> namedArguments) {
    namedArguments.forEach((sym, value) {
      String name = MirrorSystem.getName(sym);
      if (_isPathParam(name)) {
        this._path = _path.replaceFirst("{${name}}", value.toString());
      }
    });
  }

  void _concatQueryParams(Map<Symbol, dynamic> namedArguments) {
    bool first = true;

    namedArguments.forEach((sym, value) {
      String name = MirrorSystem.getName(sym);
      if (_isQueryParam(name)) {
        String concatBy = "&";
        if (first) {
          first = false;
          concatBy = "?";
        }

        this._path = "${_path}${concatBy}${name}=${value.toString()}";
      }
    });
  }

  _getBodyParam(Map<Symbol, dynamic> namedArguments) {
    dynamic body;

    namedArguments.forEach((sym, value) {
      if (MirrorSystem.getName(sym) == _body.name) {
        body = value;
        return;
      }
    });

    return body;
  }

  Future<dynamic> _get() {
    return _request(http.get(_path));
  }

  Future<dynamic> _post(body) {
    return _request(
        http.post(
            _path,
            body: body != null ? encode(body) : null
        )
    );
  }

  Future<dynamic> _put(body) {
    return _request(
        http.put(
            _path,
            body: body != null ? encode(body) : null
        )
    );
  }

  Future<dynamic> _request(Future<http.Response> req) {
    var completer = new Completer();

    req.then((response) {
      if (_returns == reflectClass(http.Response) ||
          response.body == null) {
        completer.completeError(response);
      } else {
        completer.complete(
            decode(response.body, type: _returns.reflectedType)
        );
      }
    });

    return completer.future;
  }
}