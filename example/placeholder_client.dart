import 'dart:async';
import 'package:cosmic/cosmic.dart';
import 'post.dart' as entity;

@Client("https://jsonplaceholder.typicode.com")
class PlaceholderClient extends Service {

  @Get("/posts")
  Future<List<entity.Post>> getPosts();

  @Get("/posts/{id}")
  Future<entity.Post> getPost({@Path("id") int id});

  @Post("/posts")
  Future<entity.Post> create({@Body("post") entity.Post post});

  @Patch("/posts/{id}")
  Future<entity.Post> update({@Path("id") int id, @Body("post") entity.Post post});
}