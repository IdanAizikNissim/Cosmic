part of cosmic_annotations;

class Url extends Annotation {
  final String _url;
  const Url(this._url) : super(true);

  String get url => _url;

  @override
  Annotation clone(String type) {
    return new Url(_url);
  }
}

class Path extends Annotation {
  final String _param;

  const Path(this._param, [String type]) : super(false, type);

  String get param => _param;

  @override
  Annotation clone(String type) {
    return new Path(_param, type);
  }
}

class Query extends Annotation {
  final String _query;

  const Query(this._query, [String type]) : super(false, type);

  String get query => _query;

  @override
  Annotation clone(String type) {
    return new Query(_query, type);
  }
}

class Body extends Annotation {
  final String _name;

  const Body(this._name, [String type]) : super(true, type);

  String get name => _name;

  @override
  Annotation clone(String type) {
    return new Body(_name, type);
  }
}

class HeaderMap extends Annotation {
  final String _name;

  const HeaderMap(this._name, [String type]) : super(true, type);

  String get name => _name;

  @override
  Annotation clone(String type) {
    return new HeaderMap(_name, type);
  }
}