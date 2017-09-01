import 'http_method.dart';

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

const HttpMethods = const [
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Head
];