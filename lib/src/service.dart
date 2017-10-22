part of cosmic;

class Service {
  final Map<Symbol, String> _keys = new Map<Symbol, String>();
  final Map<Symbol, dynamic> _values = new Map<Symbol, dynamic>();

  _add(String key, dynamic value) {
    _keys[new Symbol(key)] = key;
    _values[new Symbol(key)] = value;
  }

  noSuchMethod(Invocation invocation) {
    return _values[invocation.memberName](invocation.namedArguments);
  }

  Map<Symbol, dynamic> get values => _values;
}