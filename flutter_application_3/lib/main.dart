import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Importación para fuentes personalizadas

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuadrado Mágico',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MagicSquarePage(),
    );
  }
}

class MagicSquarePage extends StatefulWidget {
  const MagicSquarePage({super.key});

  @override
  _MagicSquarePageState createState() => _MagicSquarePageState();
}

// MEJORA: Se añade 'SingleTickerProviderStateMixin' para manejar animaciones.
class _MagicSquarePageState extends State<MagicSquarePage>
    with SingleTickerProviderStateMixin {
  final List<List<TextEditingController>> controllers = List.generate(
    3,
    (_) => List.generate(3, (_) => TextEditingController()),
  );
  String result = 'Ingresa los números del 1 al 9.';
  
  // MEJORA: Controladores de animación para la aparición de la cuadrícula.
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animations = List.generate(9, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }


  void resetSquare() {
    setState(() {
      for (var row in controllers) {
        for (var controller in row) {
          controller.clear();
        }
      }
      result = 'Ingresa los números del 1 al 9.';
      _animationController.reset(); // Reinicia la animación
      _animationController.forward(); // La ejecuta de nuevo
    });
  }

  bool validateMagicSquare(List<List<int>> square) {
    const int magicSum = 15;
    int n = square.length;

    for (var row in square) {
      if (row.reduce((a, b) => a + b) != magicSum) return false;
    }
    for (int col = 0; col < n; col++) {
      int columnSum = 0;
      for (int row = 0; row < n; row++) {
        columnSum += square[row][col];
      }
      if (columnSum != magicSum) return false;
    }
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
        if (controller.text.isEmpty) {
          setState(() => result = 'Por favor, llena todas las casillas.');
          return;
        }
        rowValues.add(int.parse(controller.text));
      }
      square.add(rowValues);
    }
    Set<int> uniqueNumbers = square.expand((row) => row).toSet();
    if (uniqueNumbers.length == 9 &&
        uniqueNumbers.every((num) => num >= 1 && num <= 9)) {
      setState(() => result = validateMagicSquare(square)
          ? '🎉 ¡Es un cuadrado mágico! 🎉'
          : '❌ No es un cuadrado mágico. ❌');
    } else {
      setState(() => result = '⚠️ Debes usar los números del 1 al 9, una sola vez. ⚠️');
    }
  }

  Color _getResultColor() {
    if (result.contains('🎉')) return Colors.green.shade800;
    if (result.contains('❌') || result.contains('⚠️')) return Colors.red.shade800;
    return Colors.grey.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // MEJORA: Fondo con gradiente para un look más moderno.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // MEJORA: Se usa una Card para crear un efecto de relieve (neumorfismo).
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 24),
                      _buildMagicSquareGrid(),
                      SizedBox(height: 24),
                      _buildActionButtons(),
                      SizedBox(height: 24),
                      _buildResultText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MEJORA: Widget para el encabezado de la tarjeta.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.grid_on_sharp, color: Colors.deepPurple, size: 32),
        SizedBox(width: 12),
        Text(
          'Cuadrado Mágico',
          // MEJORA: Fuente personalizada para el título.
          style: GoogleFonts.questrial(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  // MEJORA: La cuadrícula ahora tiene una animación de entrada.
  Widget _buildMagicSquareGrid() {
    int cellIndex = 0;
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (j) {
              final int index = cellIndex++;
              return FadeTransition(
                opacity: _animations[index],
                child: SlideTransition(
                  position: _animations[index].drive(
                    Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: _buildGridCell(controllers[i][j]),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
  
  // MEJORA: Widget individual para cada celda, con mejor estilo.
  Widget _buildGridCell(TextEditingController controller) {
    return SizedBox(
      width: 65,
      height: 65,
      child: TextField(
        controller: controller,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade700,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  // MEJORA: Botones con estilo mejorado y animación al presionar.
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStyledButton(
          icon: Icons.refresh,
          label: 'Limpiar',
          onPressed: resetSquare,
          color: Colors.orange.shade600,
        ),
        SizedBox(width: 20),
        _buildStyledButton(
          icon: Icons.check_circle_outline,
          label: 'Verificar',
          onPressed: checkMagicSquare,
          color: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildStyledButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  // MEJORA: Widget para el texto de resultado con animación.
  Widget _buildResultText() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        result,
        key: ValueKey<String>(result), // Necesario para que AnimatedSwitcher funcione
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _getResultColor(),
        ),
      ),
    );
  }
    }
    