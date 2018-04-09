# Cosmic

Simple work with REST JSON API for DART

## Usage

A simple usage example:  

```dart
import 'package:http/http.dart' as http;
import 'package:cosmic/converters/cosmic_converters.dart';
import 'package:cosmic/annotations/cosmic_annotations.dart';
import 'package:cosmic/cosmic.dart' as Cosmic;   
      
class Fixer {
  String base;
  String date;
  Map<String, double> rates;
}
      
@Client(
  "http://api.fixer.io", 
  converter: const JsonConverter()
)
class FixerClient extends Cosmic.Client {
  @Get("/latest")
  Future<Fixer> latest({@Query("base") String base = "USD"});
}   
      
main() async {
  Fixer latest = await fixerClient.latest();
  print(latest.date);
}
```

A middleware:

```dart
FixerClient client = new FixerClient()
  ..use((request, next) {
    print("${request.httpMethod} ${request.url}");
    request.headers["token"] = "12345";
    next();
  });
```
A converter:

```dart
import 'package:jsonx/jsonx.dart' as jsonx;
    
class JsonConverter extends Converter {
  const JsonConverter();
    
  @override
  dynamic decode(String data, {Type type}) => jsonx.decode(data, type: type);
    
  @override
  String encode(object) => jsonx.encode(object);
}
```

(check example/placeholder_client.dart for more)

## Generate
dart:mirror is absent from flutter   
use cosmic:generate in order to generate the api impl pre runtime  

    $ pub run cosmic:generate -i example/clients/def/placeholder.dart -c PlaceholderClient -o example/clients/impl -w true

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://gitlab.com/idan-aizik-nissim/dart-cosmic/issues
