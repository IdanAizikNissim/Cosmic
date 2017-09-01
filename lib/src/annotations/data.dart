import 'annotation.dart';

class Url extends Annotation {
  final String _url;
  const Url(this._url) : super(true);

  String get url => _url;
}

class Path extends Annotation {
  final String _param;
  const Path(this._param);

  String get param => _param;
}

class Query extends Annotation {
  final String _query;
  const Query(this._query);

  String get query => _query;
}