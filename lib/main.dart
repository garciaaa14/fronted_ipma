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
  final controllerLocationId = TextEditingController(text: '1010500'); // ex: Aveiro
  String _logText = '';

  void _appendLog(String text) {
    _logText += '$text\n';
    setState(() {});
  }

  @override
  void dispose() {
    controllerLocationId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: Text('Meteorologia (IPMA)')),
      body: CustomContainerMain(
        child: Column(
          children: [
            // =========================
            // BOTÕES
            // =========================
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
                              _appendLog('\n== LOCAIS ==');

                              try {
                                final list = json.decode(res) as List<dynamic>;
                                for (final item in list.take(20)) {
                                  _appendLog('ID: ${item['globalIdLocal']} | Local: ${item['local']}');
                                }
                                _appendLog('... (mostrados 20)');
                              } on FormatException {
                                _appendLog(res);
                              }
                            },
                            child: const Text('OBTER LOCAIS'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Input LocationId
                  Row(
                    children: [
                      const Text('   LocationId:'),
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
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () async {
                              final id = int.tryParse(controllerLocationId.text) ?? -1;
                              final res = await Communication.getCurrent(id);

                              _appendLog('\n== TEMPO ATUAL ($id) ==');

                              try {
                                final obj = json.decode(res) as Map<String, dynamic>;
                                _appendLog('Temperatura: ${obj['temperature']} °C');
                                _appendLog('Humidade: ${obj['humidity']} %');
                                _appendLog('Chuva acumulada: ${obj['precAcumulated']}');
                                _appendLog('Vento (km/h): ${obj['windIntensityKm']}');
                                _appendLog('Direção vento: ${obj['WindDirection'] ?? obj['windDirection']}');
                                _appendLog('Radiação: ${obj['radiation']}');
                              } on FormatException {
                                _appendLog(res);
                              }
                            },
                            child: const Text('OBTER TEMPO ATUAL'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          child: ElevatedButton(
                            style: CustomButtonStyle.buttonStyle,
                            onPressed: () async {
                              final id = int.tryParse(controllerLocationId.text) ?? -1;
                              final res = await Communication.getForecast(id);

                              _appendLog('\n== PREVISÃO 5 DIAS ($id) ==');

                              try {
                                final list = json.decode(res) as List<dynamic>;
                                for (final day in list) {
                                  _appendLog(
                                      '${day['forecastDate']} | ${day['weatherType']} | Min:${day['tMin']} Max:${day['tMax']} | Chuva:${day['precipitaProb']}% | Vento:${day['windSpeed']} ${day['predWindDir']} | icon:${day['icon']}');
                                }
                              } on FormatException {
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
