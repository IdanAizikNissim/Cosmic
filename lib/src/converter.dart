part of cosmic_lib;

abstract class Converter {
  const Converter();

  dynamic decode(String data, {Type type});
  String encode(dynamic object);
}