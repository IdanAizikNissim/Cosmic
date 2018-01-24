library cosmic_annotations;

import 'package:meta/meta.dart';
import 'package:cosmic/cosmic_lib.dart' show Converter;

part 'client.dart';
part 'data.dart';
part 'http_method.dart';
part 'http_methods.dart';

class Annotation {
  final bool _once;

  const Annotation([this._once = false]);

  bool get once => _once;
}