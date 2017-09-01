import 'annotation.dart';

class Client extends Annotation {
  final String _path;

  const Client(this._path) : super(true);

  get path => _path;
}