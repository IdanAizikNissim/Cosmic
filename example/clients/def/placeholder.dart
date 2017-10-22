import 'dart:async';
import 'package:cosmic/converters/cosmic_converters.dart';
import 'package:cosmic/cosmic.dart';
import 'package:http/http.dart' as http;
import '../../entities/post.dart' as entity;

@Client(
  path: "https://jsonplaceholder.typicode.com",
  converter: const JsonConverter()
)
class PlaceholderClient extends Service {

  @Get("/posts")
  Future<List<entity.Post>> getPosts();

  @Get("/posts/{id}")
  Future<entity.Post> getPost({@HeaderMap("headers") Map<String, String> headers, @Path("id") int id});

  @Post("/posts")
  Future<entity.Post> create({@Body("post") entity.Post post});

  @Patch("/posts/{id}")
  Future<entity.Post> update({@Path("id") int id, @Body("post") entity.Post post});

  @Delete("/posts/{id}")
  Future<http.Response> delete({@Path("id") int id});
}