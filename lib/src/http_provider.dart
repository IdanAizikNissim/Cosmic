part of cosmic;

class HttpProvider {
  HttpMethod _method;
  String _path;
  List<Path> _pathParams;
  List<Query> _queryParams;
  HeaderMap _headerMap;
  Body _body;
  Url _url;
  Type _returns;

  HttpMethod get method => _method;
  String get path => _path;
  List<Path> get pathParams => _pathParams;
  List<Query> get queryParams => _queryParams;
  HeaderMap get headerMap => _headerMap;
  Body get body => _body;
  Url get url => _url;
  Type get returns => _returns;

  HttpProvider(this._method, path, [
    this._pathParams,
    this._queryParams,
    this._headerMap,
    this._body,
    this._url,
    this._returns
  ]) {
    this._path = _getPath(path, _method, url: _url);
  }

  call(Map<Symbol, dynamic> namedArguments) {
    _injectPathParams(namedArguments);
    _concatQueryParams(namedArguments);

    // Get body
    var body =
      _body != null ? _getBodyParam(namedArguments) : null;

    // Get header map
    Map<String, String> headers =
      _headerMap != null ? _getHeaderMapParam(namedArguments) : null;

    switch (this._method.runtimeType) {
      case Get:
        return _get(headers: headers);
      case Post:
        return _post(body: body, headers: headers);
      case Put:
      case Patch:
        return _put(body: body, headers: headers);
      case Delete:
        return _delete(headers: headers);
      case Head:
        return _head(headers: headers);
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
      String name = getSymbolName(sym);
      if (_isPathParam(name)) {
        this._path = _path.replaceFirst("{${name}}", value.toString());
      }
    });
  }



  void _concatQueryParams(Map<Symbol, dynamic> namedArguments) {
    bool first = true;

    namedArguments.forEach((sym, value) {
      String name = getSymbolName(sym);
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
      if (getSymbolName(sym) == _body.name) {
        body = value;
        return;
      }
    });

    return body;
  }

  _getHeaderMapParam(Map<Symbol, dynamic> namedArguments) {
    Map<String, String> headerMap;

    namedArguments.forEach((sym, value) {
      if (getSymbolName(sym) == _headerMap.name) {
        headerMap = value;
        return;
      }
    });

    return headerMap;
  }

  Future<dynamic> _get({Map<String, String> headers}) {
    return _request(http.get(_path, headers: headers));
  }

  Future<dynamic> _post({body, Map<String, String> headers}) {
    return _request(
      http.post(
        _path,
        body: body != null ? encode(body) : null,
        headers: headers
      )
    );
  }

  Future<dynamic> _put({body, Map<String, String> headers}) {
    return _request(
      http.put(
        _path,
        body: body != null ? encode(body) : null,
        headers: headers
      )
    );
  }

  Future<dynamic> _delete({Map<String, String> headers}) {
    return _request(
      http.delete(_path, headers: headers)
    );
  }

  Future<dynamic> _head({Map<String, String> headers}) {
    return _request(
      http.head(_path, headers: headers)
    );
  }

  Future<dynamic> _request(Future<http.Response> req) {
    var completer = new Completer();

    req.then((response) {
      if (_returns == http.Response) {
        completer.complete(response);
      } else if (response.body == null) {
        completer.completeError(response);
      } else {
        completer.complete(
            decode(response.body, type: _returns)
        );
      }
    }).catchError((error) => completer.completeError(error));

    return completer.future;
  }
}