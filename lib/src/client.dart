part of cosmic;

abstract class Client {
  final Map<String, List<Middleware>> middlewares = {};
  final Map<Symbol, String> _keys = new Map<Symbol, String>();
  final Map<Symbol, dynamic> _values = new Map<Symbol, dynamic>();

  Map<Symbol, dynamic> get values => _values;

  _add(String key, dynamic value) {
    _keys[new Symbol(key)] = key;
    _values[new Symbol(key)] = value;
  }

  noSuchMethod(Invocation invocation) {
    return _values[invocation.memberName](invocation.namedArguments);
  }

  //  Middleware
  @protected
  List<Middleware> getMiddlewares(@required String path) {
    assert(path != null);
    final use = middlewares[path]?? [];
    use.addAll(middlewares[""]?? []);

    return use;
  }

  Client use(@required Middleware middleware, {String path}) {
    assert(middleware != null);
    path = path?? "";

    final pathMiddlewares = middlewares[path];
    if (pathMiddlewares == null) {
      middlewares[path] = new List<Middleware>();
    }

    middlewares[path].add(middleware);

    return this;
  }
}