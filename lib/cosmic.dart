// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library cosmic;

import 'dart:mirrors';
import 'package:cosmic/converters/cosmic_converters.dart';
import 'package:cosmic/cosmic_lib.dart';
import 'package:cosmic/annotations/cosmic_annotations.dart' as ANTN;

part 'src/gen.dart';
part 'src/parser.dart';

class Cosmic {
  static create(Client client) {
    Parser parser = new Parser();
    return parser.parse(client);
  }

  static String generate(Client client, String filename, List<String> imports, String outputPath) {
    return Gen.generate(create(client), filename, imports, outputPath);
  }
}