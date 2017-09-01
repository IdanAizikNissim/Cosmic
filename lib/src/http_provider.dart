import 'annotations/http_methods.dart';
import 'package:http/http.dart' as http;

class HttpProvider {
  static provide(httpMethod, String path, declaration) {
    // Get
    if (httpMethod is Get) {
      return _get(httpMethod as Get, path, declaration);
    }
  }

  static _get(Get httpMethod, String path, declaration) {
    return http.get("${path}${httpMethod.path}");
  }
}