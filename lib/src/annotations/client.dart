part of cosmic;

class Client extends Annotation {
  final String _path;

  const Client(this._path) : super(true);

  get path => _path;
}