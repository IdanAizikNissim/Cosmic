import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cosmic/cosmic.dart'
    show Client, Request, TypeProvider, Middleware;
import 'package:cosmic/annotations/cosmic_annotations.dart' as ANTN;
import 'package:cosmic/converters/cosmic_converters.dart' show JsonConverter;
import '../../entities/post.dart';

class PlaceholderClient extends Client {
  final url = "https://jsonplaceholder.typicode.com";
  final converter = const JsonConverter();

  Future<List<Post>> getPosts() {
    final Type returnType = const TypeProvider<List<Post>>().type;
    final String path = "/posts";

    return _callMiddleware(
        new Request(
          "$url/posts",
          http.get,
          ANTN.Get,
        ),
        returnType,
        path);
  }

  Future<Post> getPost(id, headers) {
    final Type returnType = Post;
    final String path = "/posts/{id}";

    return _callMiddleware(
        new Request("$url/posts/$id", http.get, ANTN.Get, headers: headers),
        returnType,
        path);
  }

  Future<Post> create(post) {
    final Type returnType = Post;
    final String path = "/posts";

    return _callMiddleware(
        new Request(
          "$url/posts",
          http.post,
          ANTN.Post,
          body: converter.encode(post),
        ),
        returnType,
        path);
  }

  Future<Post> update(id, post) {
    final Type returnType = Post;
    final String path = "/posts/{id}";

    return _callMiddleware(
        new Request(
          "$url/posts/$id",
          http.patch,
          ANTN.Patch,
          body: converter.encode(post),
        ),
        returnType,
        path);
  }

  Future<http.Response> delete(id) {
    final Type returnType = http.Response;
    final String path = "/posts/{id}";

    return _callMiddleware(
        new Request(
          "$url/posts/$id",
          http.delete,
          ANTN.Delete,
        ),
        returnType,
        path);
  }

  Future<dynamic> _request(Future<http.Response> req, Type returnType) {
    var completer = new Completer();

    req.then((response) {
      if (returnType == http.Response) {
        completer.complete(response);
      } else if (response.body == null) {
        completer.completeError(response);
      } else {
        completer.complete(converter.decode(response.body, type: returnType));
      }
    }).catchError((error) => completer.completeError(error));

    return completer.future;
  }

  Future<dynamic> _callMiddleware(Request request, Type returnType, String path,
      {int index = 0,
      Completer completer,
      List<Middleware> reqMiddlewares}) async {
    reqMiddlewares = reqMiddlewares ?? getMiddlewares(path);
    completer = completer ?? new Completer();

    if (index >= reqMiddlewares.length) {
      completer.complete(await _request(request.bind(), returnType));
    } else {
      reqMiddlewares[index](request, () {
        _callMiddleware(request, returnType, path,
            index: index + 1,
            completer: completer,
            reqMiddlewares: reqMiddlewares);
      });
    }

    return completer.future;
  }
}
