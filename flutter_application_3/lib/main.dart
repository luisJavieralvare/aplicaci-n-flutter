import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Cuadrado Mágico', home: MagicSquarePage());
  }
}

class MagicSquarePage extends StatefulWidget {
  @override
  _MagicSquarePageState createState() => _MagicSquarePageState();
}

class _MagicSquarePageState extends State<MagicSquarePage> {
  List<List<TextEditingController>> controllers = List.generate(
    3,
    (_) => List.generate(3, (_) => TextEditingController()),
  );
  String result = '';

  // --- NUEVA FUNCIÓN PARA LIMPIAR EL TABLERO ---
  void resetSquare() {
    setState(() {
      for (var row in controllers) {
        for (var controller in row) {
          controller.clear(); // Limpia cada campo de texto
        }
      }
      result = ''; // Limpia el mensaje de resultado
    });
  }
  // ---------------------------------------------

  bool validateMagicSquare(List<List<int>> square) {
    int n = square.length;
    // La suma mágica para un cuadrado de 3x3 con números del 1 al 9 siempre es 15.
    // Usar un valor fijo es más robusto que calcularlo de la primera fila.
    int magicSum = 15;

    // Verificar filas
    for (var row in square) {
      if (row.reduce((a, b) => a + b) != magicSum) {
        return false;
      }
    }

    // Verificar columnas
    for (int col = 0; col < n; col++) {
      int columnSum = 0;
      for (int row = 0; row < n; row++) {
        columnSum += square[row][col];
      }
      if (columnSum != magicSum) {
        return false;
      }
    }

    // Verificar diagonales
    int diagonalSum1 = 0;
    int diagonalSum2 = 0;

    for (int i = 0; i < n; i++) {
      diagonalSum1 += square[i][i];
      diagonalSum2 += square[i][n - 1 - i];
    }

    return diagonalSum1 == magicSum && diagonalSum2 == magicSum;
  }

  void checkMagicSquare() {
    List<List<int>> square = [];

    for (var row in controllers) {
      List<int> rowValues = [];
      for (var controller in row) {
        rowValues.add(int.tryParse(controller.text) ?? 0);
      }
      square.add(rowValues);
    }

    Set<int> uniqueNumbers = square.expand((x) => x).toSet();

    if (uniqueNumbers.length == 9 &&
        uniqueNumbers.every((num) => num >= 1 && num <= 9)) {
      setState(() {
        result = validateMagicSquare(square)
            ? '¡Es un cuadrado mágico!'
            : 'No es un cuadrado mágico.';
      });
    } else {
      setState(() {
        result = 'Debes usar los números del 1 al 9 sin repeticiones.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuadrado Mágico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El GridView se mantiene igual
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int j = 0; j < 3; j++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: TextField(
                            controller: controllers[i][j],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            SizedBox(height: 20),

            // --- FILA DE BOTONES MODIFICADA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón para Limpiar
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Limpiar'),
                  onPressed: resetSquare, // Llama a la nueva función
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                ),
                SizedBox(width: 16), // Espacio entre botones
                // Tu botón original
                ElevatedButton.icon(
                  icon: Icon(Icons.check),
                  label: Text('Verificar'),
                  onPressed: checkMagicSquare,
                ),
              ],
            ),

            // ----------------------------------
            SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
