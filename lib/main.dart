import 'dart:convert';
import 'package:flutter/material.dart';

import 'Comms.dart';
import 'styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Forecast usa globalIdLocal
  final controllerLocationId = TextEditingController(text: '1010500');
  // Current usa stationId
  final controllerStationId = TextEditingController(text: '1210604');

  String _logText = '';

  void _appendLog(String text) {
    _logText += '$text\n';
    setState(() {});
  }

  @override
  void dispose() {
    controllerLocationId.dispose();
    controllerStationId.dispose();
    super.dispose();
  }

  String _pick(Map<String, dynamic> obj, List<String> keys, {String fallback = ''}) {
    for (final k in keys) {
      if (obj.containsKey(k) && obj[k] != null) return obj[k].toString();
    }
    return fallback;
  }

  int? _parseInt(String s) {
    final v = int.tryParse(s.trim());
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: Text('Meteorologia (IPMA)')),
      body: CustomContainerMain(
        child: Column(
          children: [
            CustomContainerGroup(
              child: Column(
                children: [
                  // =========================
                  // LOCAIS (globalIdLocal)
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () async {
                              final res = await Communication.getLocations();
                              _appendLog('\n== LOCAIS (globalIdLocal) ==');

                              try {
                                final decoded = json.decode(res);
                                if (decoded is List) {
                                  for (final item in decoded) {
                                    final m = item as Map<String, dynamic>;
                                    _appendLog('ID: ${m['globalIdLocal']} | Local: ${m['local']}');
                                  }
                                  _appendLog('Total: ${decoded.length} locais');
                                } else {
                                  _appendLog(res);
                                }
                              } catch (_) {
                                _appendLog(res);
                              }
                            },
                            child: const Text('OBTER LOCAIS'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // =========================
                  // ESTAÇÕES (stationId)
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () async {
                              final res = await Communication.getStations();
                              _appendLog('\n== ESTAÇÕES (stationId) ==');

                              try {
                                final decoded = json.decode(res);
                                if (decoded is List) {
                                  for (final item in decoded.take(20)) {
                                    final m = item as Map<String, dynamic>;
                                    _appendLog('StationId: ${m['id']} | Nome: ${m['name']}');
                                  }
                                  _appendLog('... (mostradas 20)');
                                } else {
                                  _appendLog(res);
                                }
                              } catch (_) {
                                _appendLog(res);
                              }
                            },
                            child: const Text('OBTER ESTAÇÕES'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // INPUTS
                  // =========================
                  Row(
                    children: [
                      const Text('   LocationId (forecast):'),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: controllerLocationId,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('   StationId (current):'),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: controllerStationId,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // TEMPO ATUAL -> stationId
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () async {
                              final id = _parseInt(controllerStationId.text);
                              if (id == null) {
                                _appendLog('\nStationId inválido');
                                return;
                              }

                              final res = await Communication.getCurrent(id);
                              _appendLog('\n== TEMPO ATUAL (stationId $id) ==');

                              try {
                                final obj = json.decode(res);
                                if (obj is! Map<String, dynamic>) {
                                  _appendLog(res);
                                  return;
                                }

                                final temp = _pick(obj, ['temperature', 'temp', 'Temperature'], fallback: '—');
                                final hum = _pick(obj, ['humidity', 'rh', 'Humidity'], fallback: '—');

                                final windKm =
                                _pick(obj, ['windIntensityKm', 'windSpeedKm', 'windSpeed'], fallback: '—');
                                final windDir = _pick(obj, ['windDirection', 'WindDirection', 'windDir'], fallback: '—');

                                final prec = _pick(obj, ['precAcumulated', 'precAcumulada', 'precAccumulated'], fallback: '—');
                                final rad = _pick(obj, ['radiation', 'rad', 'Radiation'], fallback: '—');

                                _appendLog('Temperatura: $temp °C');
                                _appendLog('Humidade: $hum %');
                                _appendLog('Chuva acumulada: $prec');
                                _appendLog('Vento: $windKm | Direção: $windDir');
                                _appendLog('Radiação/UV: $rad');
                              } catch (_) {
                                _appendLog(res);
                              }
                            },
                            child: const Text('OBTER TEMPO ATUAL'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // =========================
                  // PREVISÃO 5 DIAS -> globalIdLocal
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () async {
                              final id = _parseInt(controllerLocationId.text);
                              if (id == null) {
                                _appendLog('\nLocationId inválido');
                                return;
                              }

                              final res = await Communication.getForecast(id);
                              _appendLog('\n== PREVISÃO 5 DIAS (locationId $id) ==');

                              try {
                                final list = json.decode(res) as List<dynamic>;

                                for (final day in list) {
                                  final m = day as Map<String, dynamic>;

                                  _appendLog(
                                      '${m['forecastDate']} '
                                          '| Min:${m['tMin']} Max:${m['tMax']} '
                                          '| Chuva:${m['precipitaProb']}% '
                                          '| Vento:${m['windSpeed']} ${m['predWindDir']} '
                                          '| icon:${m['icon']}'
                                  );
                                }
                              } catch (_) {
                                _appendLog(res);
                              }
                            },

                            child: const Text('OBTER PREVISÃO 5 DIAS'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // =========================
            // LOG
            // =========================
            Expanded(
              child: CustomContainerGroup(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CustomColor.scrollableList,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: CustomColor.borders),
                        ),
                        child: SingleChildScrollView(
                          child: Text(_logText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () {
                              _logText = '';
                              setState(() {});
                            },
                            child: const Text('LIMPAR LOG'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
