import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jsonx/jsonx.dart';
import '../../entities/post.dart';

class PlaceholderClient {
  Future<List<Post>> getPosts() {
    Type returnType = const TypeHelper<List<Post>>().type;

    return _request(
        http.get("https://jsonplaceholder.typicode.com/posts"), returnType);
  }

  Future<Post> getPost(id, headers) {
    Type returnType = Post;

    return _request(
        http.get("https://jsonplaceholder.typicode.com/posts/$id",
            headers: headers),
        returnType);
  }

  Future<Post> create(post) {
    Type returnType = Post;

    return _request(
        http.post(
          "https://jsonplaceholder.typicode.com/posts",
          body: encode(post),
        ),
        returnType);
  }

  Future<Post> update(id, post) {
    Type returnType = Post;

    return _request(
        http.patch(
          "https://jsonplaceholder.typicode.com/posts/$id",
          body: encode(post),
        ),
        returnType);
  }

  Future<http.Response> delete(id) {
    Type returnType = http.Response;

    return _request(
        http.delete("https://jsonplaceholder.typicode.com/posts/$id"),
        returnType);
  }

  Future<dynamic> _request(Future<http.Response> req, Type returnType) {
    var completer = new Completer();

    req.then((response) {
      if (returnType == http.Response) {
        completer.complete(response);
      } else if (response.body == null) {
        completer.completeError(response);
      } else {
        completer.complete(decode(response.body, type: returnType));
      }
    }).catchError((error) => completer.completeError(error));

    return completer.future;
  }
}
