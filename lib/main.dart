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
  final controllerLocationId = TextEditingController(text: '1010500');
  final controllerStationId = TextEditingController(text: '1210604');

  String _logText = '';

  void _appendLog(String text) {
    _logText += '$text\n';
    debugPrint(text);
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
    return int.tryParse(s.trim());
  }

  Widget _iconAsset(String iconFile) {
    if (iconFile.isEmpty || iconFile == '—') {
      return const SizedBox(width: 40, height: 40);
    }
    return Image.asset(
      'assets/icons/$iconFile',
      width: 40,
      height: 40,
      errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40),
    );
  }

  Future<void> _showForecastDialog(List<dynamic> decoded) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Previsão 5 dias'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: decoded.length,
              itemBuilder: (context, i) {
                final m = decoded[i] as Map<String, dynamic>;

                final date = _pick(m, ['forecastDate'], fallback: '—');
                final tMin = _pick(m, ['tMin'], fallback: '—');
                final tMax = _pick(m, ['tMax'], fallback: '—');
                final rainProb = _pick(m, ['precipitaProb'], fallback: '—');
                final weatherType = _pick(m, ['weatherType'], fallback: '—');
                final windSpeed = _pick(m, ['windSpeed'], fallback: '—');
                final windDir = _pick(m, ['predWindDir'], fallback: '—');
                final rainDesc = _pick(m, ['rainIntensityDesc'], fallback: '');
                final icon = _pick(m, ['icon'], fallback: '');

                final subtitle = StringBuffer()
                  ..write('$date | Min:$tMin Max:$tMax')
                  ..write(' | Chuva:$rainProb%')
                  ..write(rainDesc.isNotEmpty ? ' ($rainDesc)' : '')
                  ..write(' | Vento:$windSpeed $windDir');

                return ListTile(
                  leading: _iconAsset(icon),
                  title: Text(weatherType),
                  subtitle: Text(subtitle.toString()),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
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

                                final local = _pick(obj, ['local', 'Local'], fallback: '—');
                                final temp = _pick(obj, ['temperature', 'Temperature'], fallback: '—');
                                final hum = _pick(obj, ['humidity', 'Humidity'], fallback: '—');
                                final windKmh = _pick(obj, ['windSpeed', 'WindSpeed'], fallback: '—');
                                final windDir = _pick(obj, ['windDirection', 'WindDirection'], fallback: '—');
                                final windDesc = _pick(obj, ['windDescription', 'WindDescription'], fallback: '');
                                final prec = _pick(obj, ['precipitationAccumulated', 'PrecipitationAccumulated'], fallback: '—');
                                final rad = _pick(obj, ['radiation', 'Radiation'], fallback: '—');

                                _appendLog('Local: $local');
                                _appendLog('Temperatura: $temp °C');
                                _appendLog('Humidade: $hum %');
                                _appendLog('Chuva acumulada: $prec');
                                _appendLog('Vento: $windKmh km/h | Direção: $windDir${windDesc.isNotEmpty ? ' | $windDesc' : ''}');
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
                                final decoded = json.decode(res);
                                if (decoded is! List) {
                                  _appendLog(res);
                                  return;
                                }

                                for (final day in decoded) {
                                  final m = day as Map<String, dynamic>;

                                  final date = _pick(m, ['forecastDate'], fallback: '—');
                                  final tMin = _pick(m, ['tMin'], fallback: '—');
                                  final tMax = _pick(m, ['tMax'], fallback: '—');
                                  final rainProb = _pick(m, ['precipitaProb'], fallback: '—');
                                  final weatherType = _pick(m, ['weatherType'], fallback: '—');
                                  final windSpeed = _pick(m, ['windSpeed'], fallback: '—');
                                  final windDir = _pick(m, ['predWindDir'], fallback: '—');
                                  final rainDesc = _pick(m, ['rainIntensityDesc'], fallback: '');
                                  final icon = _pick(m, ['icon'], fallback: '');

                                  _appendLog(
                                    '$date | $weatherType | Min:$tMin Max:$tMax '
                                        '| Chuva:$rainProb%${rainDesc.isNotEmpty ? ' ($rainDesc)' : ''} '
                                        '| Vento:$windSpeed $windDir | icon:$icon',
                                  );
                                }

                                await _showForecastDialog(decoded);
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
