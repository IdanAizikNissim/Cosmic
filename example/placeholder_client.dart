import 'dart:async';
import 'package:cosmic/cosmic.dart';
import 'post.dart' as entity;

@Client("https://jsonplaceholder.typicode.com")
class PlaceholderClient extends Service {

  @Get("/posts")
  Future<List<entity.Post>> getPosts();

  @Get("/posts/{id}")
  Future<entity.Post> getPost({@Path("id") int id});
}