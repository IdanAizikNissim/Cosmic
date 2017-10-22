part of cosmic_converters;

class JsonConverter extends Converter {
  const JsonConverter();

  @override
  dynamic decode(String data, {Type type}) => jsonx.decode(data, type: type);

  @override
  String encode(object) => jsonx.encode(object);
}