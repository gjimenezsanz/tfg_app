import "package:app2/main.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class FavoritesPage extends StatefulWidget {
  @override
  _MoodLevelBarState createState() => _MoodLevelBarState();
}

class _MoodLevelBarState extends State<FavoritesPage> {
  double moodLevel = 0.7; // Nivel inicial (0.0 - Bajo, 1.0 - Alto)
  final double barWidth = 300; // Ancho de la barra

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Mood Level",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              // Calcula la nueva posición basándose en el ancho de la barra
              moodLevel += details.primaryDelta! / barWidth;
              // Mantiene el valor entre 0.0 y 1.0
              moodLevel = moodLevel.clamp(0.0, 1.0);
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Barra de fondo con gradiente
              Container(
                width: barWidth,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.yellow, Colors.red],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Indicador del estado de ánimo (icono que se mueve)
              Positioned(
                left:
                    moodLevel * (barWidth - 24), // Ajuste del icono en la barra
                child: Icon(Icons.bolt, color: Colors.black, size: 24),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Status: ${_getStatusText(moodLevel)}",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }

  String _getStatusText(double level) {
    if (level < 0.33) return "Low";
    if (level < 0.66) return "Average";
    return "High";
  }
}
