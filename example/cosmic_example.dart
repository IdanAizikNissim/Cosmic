import 'clients/placeholder.dart';
import 'package:cosmic/cosmic.dart';
import 'entities/post_entity.dart';

main() async {
  PlaceholderClient client = new PlaceholderClient()
    ..use((request, next) {
      print("${request.httpMethod} ${request.url}");
      request.headers["hello"] = "world";
      next();
    });

  client = Cosmic.create(client);

  // Get post with id: 1
  Map<String, String> headers = {
    "auth": "13325353453"
  };
  var post_1 = await client.getPost(id: 1, headers: headers);
  print("${post_1.id} - ${post_1.title}");

  // Get all posts
  var posts = await client.getPosts();
  posts.forEach((post) => print("${post.id} - ${post.title}"));

  // Create a new post
  PostEntity post = new PostEntity()
    ..title = "Hello From Dart Cosmic"
    ..body = "foo"
    ..userId = 1;

  var postResponse = await client.create(post: post);
  post.id = postResponse.id;
  print("${post.id} - ${post.title}");

  // Update post
  post.id = 1;
  post.body = "Hakuna matata!";
  post = await client.update(id: post.id, post: post);
  print("${post.id} - ${post.body}");

  // Delete
  var resp = await client.delete(id: 1);
  print(resp.body);
}