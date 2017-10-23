part of cosmic;

typedef void Middleware(
  @required Request request,
  dynamic next,
);

class Request {
  final String _url;
  final dynamic _httpCall;
  final Type _httpMethod;
  dynamic body;
  Map<String, String> headers;
  Encoding encoding;

  String get url => _url;
  Type get httpMethod => _httpMethod;

  bool get isGet => _httpMethod == ANTN.Get;
  bool get isPost => _httpMethod == ANTN.Post;
  bool get isPut => _httpMethod == ANTN.Put;
  bool get isPatch => _httpMethod == ANTN.Patch;
  bool get isDelete => _httpMethod == ANTN.Delete;

  Request(this._url, this._httpCall, this._httpMethod, {this.body, this.headers, this.encoding}) {
    assert(_url != null);
    assert(_httpCall != null);
    assert(_httpMethod != null);
    this.headers = this.headers?? {};
  }

  dynamic bind() {
    encoding = encoding?? UTF8;

    // Bind httpCall to params
    if (_httpMethod == ANTN.Get || _httpMethod == ANTN.Delete || _httpMethod == ANTN.Head) {
      return _httpCall(_url, headers: headers);
    } else if (_httpMethod == ANTN.Post || _httpMethod == ANTN.Put || _httpMethod == ANTN.Patch) {
      return _httpCall(_url, encoding: encoding, body: body, headers: headers);
    }
  }
}