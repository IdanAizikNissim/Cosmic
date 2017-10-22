import 'clients/impl/placeholder.dart';
import 'entities/post.dart';

main() async {
  PlaceholderClient client = new PlaceholderClient()
    ..use((request, next) {
      print("${request.httpMethod} ${request.url}");
      request.headers["hello"] = "world";
      next();
    });

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