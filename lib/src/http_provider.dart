part of cosmic_lib;

class HttpProvider {
  ANTN.HttpMethod _method;
  String _path;
  List<ANTN.Path> _pathParams;
  List<ANTN.Query> _queryParams;
  ANTN.HeaderMap _headerMap;
  ANTN.Body _body;
  ANTN.Url _url;
  Type _returns;
  Converter _converter;
  String _converterName;
  String _converterPackage;
  List<Middleware> _middlewares;

  ANTN.HttpMethod get method => _method;
  String get path => _path;
  List<ANTN.Path> get pathParams => _pathParams;
  List<ANTN.Query> get queryParams => _queryParams;
  ANTN.HeaderMap get headerMap => _headerMap;
  ANTN.Body get body => _body;
  ANTN.Url get url => _url;
  Type get returns => _returns;
  Converter get converter => _converter;
  String get converterName => _converterName;
  String get converterPackage => _converterPackage;
  List<Middleware> get middlewares => _middlewares;

  HttpProvider(this._method, this._path, [
    this._pathParams,
    this._queryParams,
    this._headerMap,
    this._body,
    this._url,
    this._returns,
    this._converter,
    this._converterName,
    this._converterPackage,
    this._middlewares
  ]) {
    assert(_converter != null);
    assert(_method != null);
    assert(_path != null);
  }

  call(Map<Symbol, dynamic> namedArguments) {
    _path =_getPath(_path, _method);
    _injectPathParams(namedArguments);
    _concatQueryParams(namedArguments);

    // Get body
    var body =
      _body != null ? _getBodyParam(namedArguments) : null;

    // Get header map
    Map<String, String> headers =
      _headerMap != null ? _getHeaderMapParam(namedArguments) : {};

    switch (this._method.runtimeType) {
      case ANTN.Get:
        return _get(headers: headers);
      case ANTN.Post:
        return _post(body: body, headers: headers);
      case ANTN.Put:
      case ANTN.Patch:
        return _put(body: body, headers: headers);
      case ANTN.Delete:
        return _delete(headers: headers);
      case ANTN.Head:
        return _head(headers: headers);
    }
  }

  String _getPath(String path, httpMethod, {
    ANTN.Url url
  }) {
    return url != null ? url.url : "${path}${httpMethod.path}";
  }

  bool _isPathParam(String name) {
    for (ANTN.Path p in _pathParams) {
      if (p.param == name) return true;
    }

    return false;
  }

  bool _isQueryParam(String name) {
    for (ANTN.Query q in _queryParams) {
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
    return _callMiddleware(
      new Request(_path, http.get, ANTN.Get, headers: headers)
    );
  }

  Future<dynamic> _post({body, Map<String, String> headers}) {
    return _callMiddleware(
      new Request(
        _path,
        http.post,
        ANTN.Post,
        headers: headers,
        body: body != null ? _converter.encode(body) : null
      )
    );
  }

  Future<dynamic> _put({body, Map<String, String> headers}) {
    return _callMiddleware(
      new Request(
        _path,
        http.put,
        ANTN.Put,
        headers: headers,
        body: body != null ? _converter.encode(body) : null
      )
    );
  }

  Future<dynamic> _delete({Map<String, String> headers}) {
    return _callMiddleware(
        new Request(_path, http.delete, ANTN.Delete, headers: headers)
    );
  }

  Future<dynamic> _head({Map<String, String> headers}) {
    return _callMiddleware(
      new Request(_path, http.head, ANTN.Head, headers: headers)
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
          _converter.decode(response.body, type: _returns)
        );
      }
    }).catchError((error) => completer.completeError(error));

    return completer.future;
  }

  Future<dynamic> _callMiddleware(Request request, {int index = 0, Completer completer}) async {
    completer = completer?? new Completer();

    if (index >= _middlewares.length) {
      completer.complete(await _request(request.bind()));
    } else {
      _middlewares[index](request, () => _callMiddleware(request, index: index + 1, completer: completer));
    }

    return completer.future;
  }
}