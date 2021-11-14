import 'dart:async';
import 'package:http/http.dart' as http;

class CountriesApi {
  static Future getCountries() {
    var url = Uri.parse("https://api.first.org/data/v1/countries");
    return http.get(url);
  }
}
