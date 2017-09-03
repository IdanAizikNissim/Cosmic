// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library cosmic;

export 'package:cosmic/src/annotations/client.dart';
export 'package:cosmic/src/annotations/data.dart';
export 'package:cosmic/src/annotations/http_methods.dart';
export 'src/service.dart';

import 'src/gen.dart';
import 'src/service.dart';
import 'src/parser.dart';

class Cosmic {
  static create(Service service) {
    Parser parser = new Parser();
    return parser.parse(service);
  }

  static String generate(Service service, List<String> imports, String outputPath) {
    return Gen.generate(create(service), imports, outputPath);
  }
}