import 'dart:convert' show JsonDecoder, JsonEncoder;
import 'package:cosmic/cosmic_lib.dart' show Converter;
import 'entities/post_entity.dart';

class PostEntityConverter extends Converter<PostEntity> {
  const PostEntityConverter();
  
  @override
  dynamic decode(String data, {Type type}) {
    final object = JsonDecoder().convert(data);

    if (object is List) {
      return object.map((obj) => PostEntity.fromJSON(obj)).toList(growable: false);
    } else {
      return PostEntity.fromJSON(object);
    }
  }

  @override
  String encode(PostEntity object) {
    return object.toJSON();
  }
}