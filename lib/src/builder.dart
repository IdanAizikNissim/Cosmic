part of cosmic_lib;

Builder cosmicBuilder(BuilderOptions options) {
  return new LibraryBuilder(
    new ClientGenerator(),
    formatOutput: new DartFormatter().format,
  );
}