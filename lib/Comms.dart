import 'dart:async';
import 'package:http/http.dart' as http;

class Communication {
  static String baseUrl = 'http://10.0.2.2:5292/api/weather';
  static int timeoutSec = 8;

  static Map<String, String> headersJson = {
    'Accept': 'application/json; charset=utf-8',
  };

  static Future<String> getLocations() async {
    return _get('$baseUrl/locations');
  }

  static Future<String> getStations() async {
    return _get('$baseUrl/stations');
  }

  // Aqui estás a passar stationId (mesmo que a variável se chame locationId)
  static Future<String> getCurrent(int stationId) async {
    return _get('$baseUrl/current/$stationId');
  }

  static Future<String> getForecast(int locationId) async {
    return _get('$baseUrl/forecast/$locationId');
  }

  static Future<String> _get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headersJson)
          .timeout(Duration(seconds: timeoutSec));
      return validateComm(response);
    } on Exception {
      return 'Não foi possível contactar o servidor';
    }
  }

  static String validateComm(http.Response response) {
    if (response.statusCode == 200) {
      return response.body;
    }
    if (response.statusCode == 404) return 'Não encontrado (404)';
    if (response.statusCode == 400) return response.body.toString();
    if (response.statusCode == 405) return 'Pedido não permitido (405)';
    if (response.statusCode == 415) return 'Formato errado (415)';
    return 'Erro ${response.statusCode}';
  }
}
