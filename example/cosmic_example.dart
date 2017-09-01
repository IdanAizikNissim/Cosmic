// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'placeholder_client.dart';
import 'package:cosmic/cosmic.dart';
import 'post.dart' as entity;

main() {
  PlaceholderClient service = Cosmic.create(new PlaceholderClient());

  service.getPost(id: 1).then((post) {
    print("${post.id} - ${post.title}");
  });

  service.getPosts().then((posts) {
    posts.forEach((post) => print("${post.id} - ${post.title}"));
  });

  entity.Post post = new entity.Post()
    ..title = "Hello From Dart Cosmic"
    ..body = "foo"
    ..userId = 1;

  service.create(post: post).then((p) {
    post.id = p.id;
    print("Post: ${post.id} - ${post.title} created");
  });
}

