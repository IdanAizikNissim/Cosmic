library cosmic_annotations;

import 'package:meta/meta.dart';
import 'package:cosmic/cosmic_lib.dart' show Converter;

part 'client.dart';
part 'data.dart';
part 'http_method.dart';
part 'http_methods.dart';

abstract class Annotation {
  final bool _once;
  final String _type;

  const Annotation([this._once = false, this._type]);

  bool get once => _once;
  String get type => _type;

  Annotation clone(String type);
}