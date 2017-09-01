import 'annotation.dart';

class Client extends Annotation {
  final String _path;

  const Client(this._path) : super(true);
  Client.empty([this._path = ""]) : super(true);
}