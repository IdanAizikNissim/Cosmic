import 'dart:mirrors';

import 'package:http/http.dart' as http;
import 'annotations/http_method.dart';
import 'annotations/http_methods.dart';
import 'annotations/data.dart';

class HttpProvider {
  HttpMethod _method;
  String _path;
  List<Path> _pathParams;
  List<Query> _queryParams;
  Url _url;

  HttpProvider(this._method, path, [
    this._pathParams,
    this._queryParams,
    this._url
  ]) {
    this._path = _getPath(path, _method, url: _url);
  }

  call(Map<Symbol, dynamic> namedArguments) {
    _injectPathParams(namedArguments);
    _concatQueryParams(namedArguments);

    switch (this._method.runtimeType) {
      case Get:
        return _get();
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

  _get() {
    return http.get(_path);
  }
}