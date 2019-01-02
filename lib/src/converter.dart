part of cosmic_lib;

abstract class Converter<T> {
  const Converter();

  dynamic decode(String data, {Type type});
  String encode(T object);
}