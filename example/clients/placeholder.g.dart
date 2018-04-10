// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: ClientGenerator
// **************************************************************************

part of 'placeholder.dart';

abstract class _$PlaceholderClient {
  final url = "https://jsonplaceholder.typicode.com";
  final converter = const JsonConverter();

  Future<List<PostEntity>> getPosts() {
    final Type returnType = const Cosmic.TypeProvider<List<PostEntity>>().type;
    final String path = "/posts";

    return _callMiddleware(
        new Cosmic.Request(
          "$url/posts",
          http.get,
          Get,
        ),
        returnType,
        path);
  }

  Future<PostEntity> getPost({int id, Map headers}) {
    final Type returnType = PostEntity;
    final String path = "/posts/{id}";

    return _callMiddleware(
        new Cosmic.Request("$url/posts/$id", http.get, Get, headers: headers),
        returnType,
        path);
  }

  Future<PostEntity> create({PostEntity post}) {
    final Type returnType = PostEntity;
    final String path = "/posts";

    return _callMiddleware(
        new Cosmic.Request(
          "$url/posts",
          http.post,
          Post,
          body: converter.encode(post),
        ),
        returnType,
        path);
  }

  Future<PostEntity> update({int id, PostEntity post}) {
    final Type returnType = PostEntity;
    final String path = "/posts/{id}";

    return _callMiddleware(
        new Cosmic.Request(
          "$url/posts/$id",
          http.patch,
          Patch,
          body: converter.encode(post),
        ),
        returnType,
        path);
  }

  Future<http.Response> delete({int id}) {
    final Type returnType = http.Response;
    final String path = "/posts/{id}";

    return _callMiddleware(
        new Cosmic.Request(
          "$url/posts/$id",
          http.delete,
          Delete,
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

  Future<dynamic> _callMiddleware(
      Cosmic.Request request, Type returnType, String path,
      {int index = 0,
      Completer completer,
      List<Cosmic.Middleware> reqMiddlewares}) async {
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

  List<Cosmic.Middleware> getMiddlewares(String path);
}
