import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller 1',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable de estado para el título de la AppBar
  String _tituloAppBar = "Hola, Flutter";

  // Función para alternar el título y mostrar el SnackBar
  void _cambiarTitulo() {
    setState(() {
      if (_tituloAppBar == "Hola, Flutter") {
        _tituloAppBar = "¡Título cambiado!";
      } else {
        _tituloAppBar = "Hola, Flutter";
      }
    });

    // Mostrar el SnackBar obligatorio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Título actualizado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nombre completo del estudiante
            const Center(
              child: Text(
                'Estudiante: Jimy Fabián Ramírez Tinjacá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Imágenes en un Row (Network + Asset)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://picsum.photos/120',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón obligatorio con setState()
            ElevatedButton(
              onPressed: _cambiarTitulo,
              child: const Text('Cambiar Título AppBar'),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 10),

            // WIDGET ADICIONAL 1: Container personalizado
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.indigo, width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Widget Adicional 1: Container con decoración, bordes y márgenes.',
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // WIDGET ADICIONAL 2: ListView simple
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Widget Adicional 2: ListView de elementos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text('Elemento 1: Estado administrado'),
                ),
                ListTile(
                  leading: Icon(Icons.widgets, color: Colors.blue),
                  title: Text('Elemento 2: Layouts en Flutter'),
                ),
                ListTile(
                  leading: Icon(Icons.merge_type, color: Colors.orange),
                  title: Text('Elemento 3: Integración con Git'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}