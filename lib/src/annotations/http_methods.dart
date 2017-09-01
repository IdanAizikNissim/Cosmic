import 'annotation.dart';

abstract class HttpMethod extends Annotation {
  final String _path;

  const HttpMethod(this._path);

  String get path => _path;
}

class Get extends HttpMethod {
  const Get(String path) : super(path);
}

class Post extends HttpMethod {
  const Post(String path) : super(path);
}

class Put extends HttpMethod {
  const Put(String path) : super(path);
}

class Patch extends HttpMethod {
  const Patch(String path) : super(path);
}

class Delete extends HttpMethod {
  const Delete(String path) : super(path);
}

class Head extends HttpMethod {
  const Head(String path) : super(path);
}