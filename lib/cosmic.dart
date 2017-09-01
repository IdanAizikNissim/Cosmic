// Copyright (c) 2017, Idan Aizik-Nissim. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library cosmic;

export 'package:cosmic/src/annotations/client.dart';
export 'package:cosmic/src/annotations/http_methods.dart';
export 'src/service.dart';

import 'src/service.dart';
import 'src/parser.dart';

class Cosmic {
  static create(Service service) {
    Parser parser = new Parser();
    parser.parse(service);
  }
}