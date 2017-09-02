    import 'dart:async';

    import 'package:http/http.dart' as http;

    import 'package:jsonx/jsonx.dart';

import '../../entities/post.dart';


    class PlaceholderClient {


        Future<List<Post>> getPosts() {
      Type returnType = const TypeHelper<List<Post>>().type;

          var completer = new Completer();


    http.get("https://jsonplaceholder.typicode.com/posts"
      
      ).then((response) {
      if (returnType == http.Response ||
          response.body == null) {
        completer.complete(response);
      } else {
        completer.complete(
            decode(response.body, type: returnType)
        );
      }
    });


    return completer.future;
    
    }
    
    Future<Post> getPost(id,headers) {
      Type returnType = Post;

          var completer = new Completer();


    http.get("https://jsonplaceholder.typicode.com/posts/$id"
      
      , headers: headers).then((response) {
      if (returnType == http.Response ||
          response.body == null) {
        completer.complete(response);
      } else {
        completer.complete(
            decode(response.body, type: returnType)
        );
      }
    });


    return completer.future;
    
    }
    
    Future<Post> create(post) {
      Type returnType = Post;

          var completer = new Completer();


    http.post("https://jsonplaceholder.typicode.com/posts"
      , body: encode(post),
      ).then((response) {
      if (returnType == http.Response ||
          response.body == null) {
        completer.complete(response);
      } else {
        completer.complete(
            decode(response.body, type: returnType)
        );
      }
    });


    return completer.future;
    
    }
    
    Future<Post> update(id,post) {
      Type returnType = Post;

          var completer = new Completer();


    http.patch("https://jsonplaceholder.typicode.com/posts/$id"
      , body: encode(post),
      ).then((response) {
      if (returnType == http.Response ||
          response.body == null) {
        completer.complete(response);
      } else {
        completer.complete(
            decode(response.body, type: returnType)
        );
      }
    });


    return completer.future;
    
    }
    
    Future<http.Response> delete(id) {
      Type returnType = http.Response;

          var completer = new Completer();


    http.delete("https://jsonplaceholder.typicode.com/posts/$id"
      
      ).then((response) {
      if (returnType == http.Response ||
          response.body == null) {
        completer.complete(response);
      } else {
        completer.complete(
            decode(response.body, type: returnType)
        );
      }
    });


    return completer.future;
    
    }
    
    }
    