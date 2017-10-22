// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library cosmic;

import 'dart:mirrors';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:jsonx/jsonx.dart';

part 'src/service.dart';
part 'src/gen.dart';
part 'src/utils.dart';
part 'src/annotations/annotation.dart';
part 'src/annotations/client.dart';
part 'src/annotations/data.dart';
part 'src/annotations/http_method.dart';
part 'src/annotations/http_methods.dart';
part 'src/http_provider.dart';
part 'src/parser.dart';

class Cosmic {
  static create(Service service) {
    Parser parser = new Parser();
    return parser.parse(service);
  }

  static String generate(Service service, List<String> imports, String outputPath) {
    return Gen.generate(create(service), imports, outputPath);
  }
}