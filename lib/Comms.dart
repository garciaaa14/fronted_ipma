import 'dart:async';
import 'package:http/http.dart' as http;

class Communication {
  static String baseUrl = 'http://10.0.2.2:5292/api/weather';
  static int timeoutSec = 5;

  static Map<String, String> headersJson = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json; charset=utf-8',
  };

  // =========================
  // LOCAIS
  // =========================
  static Future<String> getLocations() async {
    final url = '$baseUrl/locations';
    try {
      http.Response response =
      await http.get(Uri.parse(url), headers: headersJson).timeout(Duration(seconds: timeoutSec));
      return validateComm(response);
    } on Exception {
      return 'Não foi possível contactar o servidor';
    }
  }

  // =========================
  // TEMPO ATUAL
  // =========================
  static Future<String> getCurrent(int locationId) async {
    final url = '$baseUrl/current/$locationId';
    try {
      http.Response response =
      await http.get(Uri.parse(url), headers: headersJson).timeout(Duration(seconds: timeoutSec));
      return validateComm(response);
    } on Exception {
      return 'Não foi possível contactar o servidor';
    }
  }

  // =========================
  // PREVISÃO 5 DIAS
  // =========================
  static Future<String> getForecast(int locationId) async {
    final url = '$baseUrl/forecast/$locationId';
    try {
      http.Response response =
      await http.get(Uri.parse(url), headers: headersJson).timeout(Duration(seconds: timeoutSec));
      return validateComm(response);
    } on Exception {
      return 'Não foi possível contactar o servidor';
    }
  }

  // =========================
  // VALIDAR RESPOSTA
  // =========================
  static String validateComm(http.Response response) {
    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 404) {
      return 'Não foi encontrada uma forma para responder ao pedido (404)';
    } else if (response.statusCode == 400) {
      return response.body.toString();
    } else if (response.statusCode == 405) {
      return 'Pedido não permitido (405)';
    } else if (response.statusCode == 415) {
      return 'Pedido com dados enviados no formato errado (415)';
    } else {
      return 'Erro ${response.statusCode}';
    }
  }
}
