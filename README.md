# cosmic

Simple work with REST JSON API for DART

## Usage

A simple usage example:  
(check example/placeholder_client.dart for more)

    import 'package:cosmic/cosmic.dart';
    
    class Fixer {
        String base;
        String date;
        Map<String, double> rates;
    }
      
    @Client("http://api.fixer.io")
    class FixerClient extends Service{
      @Get("/latest")
      Future<Fixer> latest({@Query("base") String base = "USD"});
    }
    
    main() async {
      Fixer latest = await fixerClient.latest();
      print(latest.date);
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://gitlab.com/idan-aizik-nissim/dart-cosmic/issues
