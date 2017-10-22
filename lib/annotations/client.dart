part of cosmic_annotations;

class Client extends Annotation {
  final String path;
  final Converter converter;

  const Client({@required this.path, @required this.converter}) : super(true);
}