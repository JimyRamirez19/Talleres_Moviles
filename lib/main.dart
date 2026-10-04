import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

// ============================================================
// ISOLATE
// ============================================================

// Función que se ejecutará dentro del Isolate.
// Debe estar fuera de una clase para poder ser usada por
// Isolate.spawn.
void tareaPesada(SendPort sendPort) {
  final stopwatch = Stopwatch()..start();

  // Tarea CPU-bound: realizar una suma grande.
  const int limite = 100000000;
  int suma = 0;

  for (int i = 1; i <= limite; i++) {
    suma += i;
  }

  stopwatch.stop();

  // Enviamos el resultado al Isolate principal.
  sendPort.send({
    'resultado': suma,
    'tiempo': stopwatch.elapsedMilliseconds,
  });
}

// ============================================================
// APLICACIÓN
// ============================================================

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller Segundo Plano',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// PANTALLA PRINCIPAL
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==========================================================
  // FUTURE + ASYNC/AWAIT
  // ==========================================================

  String _estadoFuture = 'Presiona el botón para iniciar.';
  bool _cargandoFuture = false;
  bool _simularError = false;

  Future<String> _simularServicio() async {
    print('2. Future: esperando respuesta del servicio...');

    // Simulamos una respuesta de un servicio externo.
    await Future.delayed(const Duration(seconds: 3));

    if (_simularError) {
      throw Exception('Error simulado del servicio.');
    }

    print('3. Future: servicio completado.');

    return 'Datos recibidos correctamente.';
  }

  Future<void> _ejecutarFuture() async {
    print('----------------------------------------');
    print('1. Future: inicio de operación.');

    setState(() {
      _cargandoFuture = true;
      _estadoFuture = 'Cargando...';
    });

    try {
      final resultado = await _simularServicio();

      if (!mounted) return;

      setState(() {
        _estadoFuture = resultado;
        _cargandoFuture = false;
      });

      print('4. Future: resultado recibido.');
      print('Resultado: $resultado');
      print('----------------------------------------');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _estadoFuture = 'Ocurrió un error en el servicio.';
        _cargandoFuture = false;
      });

      print('4. Future: error recibido.');
      print('Error: $e');
      print('----------------------------------------');
    }
  }

  // ==========================================================
  // TIMER
  // ==========================================================

  Timer? _timer;

  int _segundos = 0;

  bool _timerIniciado = false;
  bool _timerPausado = false;

  void _iniciarTimer() {
    _timer?.cancel();

    setState(() {
      _segundos = 0;
      _timerIniciado = true;
      _timerPausado = false;
    });

    _crearTimer();

    print('Timer: iniciado.');
  }

  void _crearTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          _segundos++;
        });
      },
    );
  }

  void _pausarTimer() {
    _timer?.cancel();

    setState(() {
      _timerPausado = true;
    });

    print('Timer: pausado.');
  }

  void _reanudarTimer() {
    if (!_timerIniciado) return;

    _timer?.cancel();

    setState(() {
      _timerPausado = false;
    });

    _crearTimer();

    print('Timer: reanudado.');
  }

  void _reiniciarTimer() {
    _timer?.cancel();

    setState(() {
      _segundos = 0;
      _timerIniciado = false;
      _timerPausado = false;
    });

    print('Timer: reiniciado.');
  }

  String _formatearTiempo() {
    final minutos = _segundos ~/ 60;
    final segundos = _segundos % 60;

    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundos.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // ISOLATE
  // ==========================================================

  bool _isolateEjecutando = false;

  String _resultadoIsolate = 'Todavía no se ha ejecutado la tarea.';
  int? _tiempoIsolate;

  Future<void> _ejecutarIsolate() async {
    if (_isolateEjecutando) return;

    setState(() {
      _isolateEjecutando = true;
      _resultadoIsolate = 'Ejecutando tarea pesada...';
      _tiempoIsolate = null;
    });

    print('----------------------------------------');
    print('Isolate: iniciando tarea pesada.');

    final receivePort = ReceivePort();

    try {
      await Isolate.spawn(
        tareaPesada,
        receivePort.sendPort,
      );

      print('Isolate: tarea enviada al segundo plano.');

      final mensaje = await receivePort.first as Map<String, dynamic>;

      final resultado = mensaje['resultado'] as int;
      final tiempo = mensaje['tiempo'] as int;

      if (!mounted) return;

      setState(() {
        _resultadoIsolate =
            'Suma de 1 hasta 100.000.000:\n$resultado';
        _tiempoIsolate = tiempo;
        _isolateEjecutando = false;
      });

      print('Isolate: resultado recibido.');
      print('Resultado: $resultado');
      print('Tiempo dentro del Isolate: $tiempo ms');
      print('----------------------------------------');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _resultadoIsolate = 'Error al ejecutar el Isolate: $e';
        _isolateEjecutando = false;
      });

      print('Isolate: error $e');
      print('----------------------------------------');
    } finally {
      receivePort.close();
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    // Cancelamos el Timer cuando la pantalla se destruye.
    _timer?.cancel();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programación asíncrona'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ==================================================
            // ENCABEZADO
            // ==================================================

            const Text(
              'Taller: Programación asíncrona',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Future • Timer • Isolate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Estudiante: Jimy Fabián Ramírez Tinjacá',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SECCIÓN 1 - FUTURE
            // ==================================================

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Text(
                      '1. Future + async/await',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Simulación de un servicio que tarda 3 segundos '
                      'en responder.',
                      style: TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.indigo.shade50,
                      ),
                      child: Column(
                        children: [

                          if (_cargandoFuture)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: CircularProgressIndicator(),
                            ),

                          Text(
                            _estadoFuture,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Simular error',
                      ),
                      subtitle: const Text(
                        'Actívalo para demostrar el estado Error.',
                      ),
                      value: _simularError,
                      onChanged: _cargandoFuture
                          ? null
                          : (valor) {
                              setState(() {
                                _simularError = valor;
                              });
                            },
                    ),

                    const SizedBox(height: 8),

                    ElevatedButton.icon(
                      onPressed:
                          _cargandoFuture ? null : _ejecutarFuture,
                      icon: const Icon(Icons.cloud_download),
                      label: const Text(
                        'Ejecutar Future',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SECCIÓN 2 - TIMER
            // ==================================================

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Text(
                      '2. Timer - Cronómetro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'El tiempo se actualiza cada segundo.',
                      style: TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black87,
                      ),
                      child: Text(
                        _formatearTiempo(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [

                        ElevatedButton.icon(
                          onPressed:
                              _timerIniciado ? null : _iniciarTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Iniciar'),
                        ),

                        ElevatedButton.icon(
                          onPressed: _timerIniciado &&
                                  !_timerPausado
                              ? _pausarTimer
                              : null,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pausar'),
                        ),

                        ElevatedButton.icon(
                          onPressed: _timerIniciado &&
                                  _timerPausado
                              ? _reanudarTimer
                              : null,
                          icon: const Icon(Icons.play_circle),
                          label: const Text('Reanudar'),
                        ),

                        ElevatedButton.icon(
                          onPressed: _reiniciarTimer,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reiniciar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SECCIÓN 3 - ISOLATE
            // ==================================================

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Text(
                      '3. Isolate',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Ejecuta una tarea que requiere procesamiento '
                      'intensivo utilizando Isolate.spawn.',
                      style: TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.green.shade50,
                      ),
                      child: Text(
                        _resultadoIsolate,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_tiempoIsolate != null)
                      Text(
                        'Tiempo de ejecución: $_tiempoIsolate ms',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: _isolateEjecutando
                          ? null
                          : _ejecutarIsolate,
                      icon: const Icon(Icons.memory),
                      label: Text(
                        _isolateEjecutando
                            ? 'Ejecutando...'
                            : 'Ejecutar Isolate',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PIE
            // ==================================================

            const Text(
              'Programación asíncrona en Flutter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}