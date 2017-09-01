import 'dart:async';
import 'package:cosmic/cosmic.dart';
import 'post.dart' as entity;

@Client("https://jsonplaceholder.typicode.com")
abstract class PlaceholderClient {

  @Get("/posts")
  Future<List<entity.Post>> getPosts();
}