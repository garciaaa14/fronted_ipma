import 'dart:async';
import 'package:http/http.dart' as http;

class Communication {
  static const String baseUrl = 'http://10.0.2.2:5292/api/weather';
  static const int timeoutSec = 8;

  static const Map<String, String> headersJson = {
    'Accept': 'application/json; charset=utf-8',
  };

  static Future<String> getLocations() => _get('$baseUrl/locations');
  static Future<String> getStations() => _get('$baseUrl/stations');
  static Future<String> getCurrent(int stationId) => _get('$baseUrl/current/$stationId');
  static Future<String> getForecast(int locationId) => _get('$baseUrl/forecast/$locationId');

  static Future<String> _get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headersJson)
          .timeout(const Duration(seconds: timeoutSec));
      return validateComm(response);
    } on TimeoutException {
      return 'Timeout a contactar o servidor';
    } catch (_) {
      return 'Não foi possível contactar o servidor';
    }
  }

  static String validateComm(http.Response response) {
    if (response.statusCode == 200) return response.body;
    if (response.statusCode == 404) return 'Não encontrado (404)';
    if (response.statusCode == 400) return response.body;
    if (response.statusCode == 405) return 'Pedido não permitido (405)';
    if (response.statusCode == 415) return 'Formato errado (415)';
    return 'Erro ${response.statusCode}: ${response.body}';
  }
}
