// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library cosmic;

import 'dart:mirrors';
import 'package:meta/meta.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:cosmic/converters/cosmic_converters.dart';
import 'package:cosmic/annotations/cosmic_annotations.dart' as ANTN;
import 'dart:convert' show Encoding, UTF8;

part 'src/client.dart';
part 'src/gen.dart';
part 'src/utils.dart';
part 'src/http_provider.dart';
part 'src/parser.dart';
part 'src/converter.dart';
part 'src/type_provider.dart';
part 'src/middleware.dart';

class Cosmic {
  static create(Client client) {
    Parser parser = new Parser();
    return parser.parse(client);
  }

  static String generate(Client client, List<String> imports, String outputPath) {
    return Gen.generate(create(client), imports, outputPath);
  }
}