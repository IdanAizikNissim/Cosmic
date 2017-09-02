// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'clients/impl/placeholder.dart';
import 'entities/post.dart';

main() async {
  PlaceholderClient client = new PlaceholderClient();
  var posts = await client.getPosts();
  posts.forEach((post) => print(post.id));

  var post = await client.getPost(33, null);
  print(post.id);

  var newPost = new Post()
    ..body = "Hello"
    ..title = "World"
    ..userId = 1;

  var res = await client.create(post);
  newPost.id = res.id;
  print(newPost.id);

  var result = await client.delete(10);
  print("${result.statusCode} ${result.body}");

  var updateRes = await client.update(5, newPost);
  print("${updateRes.id} ${updateRes.title}");
}

//import 'clients/def/placeholder.dart';
//import 'package:cosmic/cosmic.dart';
//import 'entities/post.dart' as entity;

//PlaceholderClient service = Cosmic.create(new PlaceholderClient());

//main() async {
//  // Get post with id: 1
//  Map<String, String> headers = {
//    "auth": "13325353453"
//  };
//  var post_1 = await service.getPost(id: 1, headers: headers);
//  print("${post_1.id} - ${post_1.title}");
//
//  // Get all posts
//  var posts = await service.getPosts();
//  posts.forEach((post) => print("${post.id} - ${post.title}"));
//
//  // Create a new post
//  entity.Post post = new entity.Post()
//    ..title = "Hello From Dart Cosmic"
//    ..body = "foo"
//    ..userId = 1;
//
//  var postResponse = await service.create(post: post);
//  post.id = postResponse.id;
//  print("${post.id} - ${post.title}");
//
//  // Update post
//  post.id = 1;
//  post.body = "Hakuna matata!";
//  post = await service.update(id: post.id, post: post);
//  print("${post.id} - ${post.body}");
//
//  // Delete
//  var resp = await service.delete(id: 1);
//  print(resp.body);
//}