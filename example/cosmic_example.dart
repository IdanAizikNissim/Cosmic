// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'placeholder_client.dart';
import 'package:cosmic/cosmic.dart';
import 'post.dart' as entity;

PlaceholderClient service = Cosmic.create(new PlaceholderClient());

main() async {
  // Get post with id: 1
  Map<String, String> headers = {
    "auth": "13325353453"
  };
  var post_1 = await service.getPost(id: 1, headers: headers);
  print("${post_1.id} - ${post_1.title}");

  // Get all posts
  var posts = await service.getPosts();
  posts.forEach((post) => print("${post.id} - ${post.title}"));

  // Create a new post
  entity.Post post = new entity.Post()
    ..title = "Hello From Dart Cosmic"
    ..body = "foo"
    ..userId = 1;

  var postResponse = await service.create(post: post);
  post.id = postResponse.id;
  print("${post.id} - ${post.title}");

  // Update post
  post.id = 1;
  post.body = "Hakuna matata!";
  post = await service.update(id: post.id, post: post);
  print("${post.id} - ${post.body}");

  // Delete
  var resp = await service.delete(id: 1);
  print(resp.body);
}