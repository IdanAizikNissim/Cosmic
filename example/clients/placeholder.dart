import 'dart:async';
import 'package:cosmic/annotations/cosmic_annotations.dart';
import 'package:cosmic/cosmic_lib.dart' as Cosmic;
import 'package:http/http.dart' as http;
import '../entities/post_entity.dart';
import '../post_entity_converter.dart';

part 'placeholder.g.dart';

@Client(
  path: "https://jsonplaceholder.typicode.com",
  converter: const PostEntityConverter()
)
class PlaceholderClient extends Cosmic.Client with _$PlaceholderClient {

  @Get("/posts")
  Future<List<PostEntity>> getPosts();

  @Get("/posts/{id}")
  Future<PostEntity> getPost({@HeaderMap("headers") Map headers, @Path("id") int id});

  @Post("/posts")
  Future<PostEntity> create({@Body("post") PostEntity post});

  @Patch("/posts/{id}")
  Future<PostEntity> update({@Path("id") int id, @Body("post") PostEntity post});

  @Delete("/posts/{id}")
  Future<http.Response> delete({@Path("id") int id});
}