class PostEntity {
  int userId;
  int id;
  String title;
  String body;

  PostEntity();

  PostEntity.fromJSON(Map<String, dynamic> data) {
    userId = data["userId"];
    id = data["id"];
    title = data["title"];
    body = data["body"];
  }

  String toJSON() {
    return """
    {
      "userId": $userId,
      "id": $id,
      "title": $title,
      "body": $body
    }
    """;
  }
}
