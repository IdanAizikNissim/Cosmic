part of cosmic_annotations;

class HttpMethod extends Annotation {
  final String _path;

  const HttpMethod(this._path) : super(false);

  String get path => _path;

  @override
  Annotation clone(String type) {
    return new HttpMethod(_path);
  }
}