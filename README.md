# Cosmic

Simple work with REST JSON API for DART

## Usage

A simple usage example:  

    import 'package:cosmic/cosmic.dart';   
      
    class Fixer {
        String base;
        String date;
        Map<String, double> rates;
    }
      
    @Client(
      "http://api.fixer.io", 
      converter: const JsonConverter()
    )
    class FixerClient extends Service{
      @Get("/latest")
      Future<Fixer> latest({@Query("base") String base = "USD"});
    }   
      
    main() async {
      Fixer latest = await fixerClient.latest();
      print(latest.date);
    }
(check example/placeholder_client.dart for more)

## Generate
dart:mirror is absent from flutter   
use cosmic:generate in order to generate the api impl pre runtime  

    $ pub run cosmic:generate -i example/clients/def/placeholder.dart -c PlaceholderClient -o example/clients/impl -w true

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://gitlab.com/idan-aizik-nissim/dart-cosmic/issues
