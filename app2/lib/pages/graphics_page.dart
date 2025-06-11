import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'recommendations/recommendation_page.dart';
import 'recommendations/llmrecommend_page.dart';

class GraphicPage extends StatefulWidget {
  @override
  _GraphicPageState createState() => _GraphicPageState();
}

class _GraphicPageState extends State<GraphicPage> {
  List<FlSpot> depressionData = [];
  List<FlSpot> anxietyData = [];
  List<FlSpot> stressData = [];
  List<FlSpot> moodData = [];
  List<FlSpot> flagCountData = []; // ← NUEVO: datos de número de flags

  @override
  void initState() {
    super.initState();
    _fetchSessionData(); // renombrado para claridad
  }

  Future<void> _fetchSessionData() async {
    try {
      // 1) Traer las últimas 5 sesiones, de la más reciente a la más antigua
      final snapshot = await FirebaseFirestore.instance
          .collection("sessions")
          .orderBy("timestamp", descending: true)
          .limit(5)
          .get();

      // 2) Listas temporales para cada parámetro
      final sessionScores = {
        "depression": <double>[],
        "anxiety": <double>[],
        "stress": <double>[],
      };
      final sessionMoods = <double>[];
      final sessionFlagCounts = <double>[]; // ← NUEVO

      // 3) Extraer datos de cada sesión en orden cronológico (invertimos)
      for (var doc in snapshot.docs.reversed) {
        final raw = doc.data();
        final data = Map<String, dynamic>.from(raw as Map);
        final scores = Map<String, dynamic>.from(
            data["scores"] != null ? data["scores"] as Map : {});
        final mood = Map<String, dynamic>.from(
            data["mood"] != null ? data["mood"] as Map : {});

        // ← sustituyo aquí la línea antigua
        final rawFlags = data["flags"];
        final List<dynamic> flags = rawFlags is List
            ? rawFlags
            : rawFlags is Map
                ? [rawFlags]
                : [];

        // Scores
        sessionScores["depression"]!
            .add((scores["scoreDepression"] ?? 0).toDouble());
        sessionScores["anxiety"]!.add((scores["scoreAnxiety"] ?? 0).toDouble());
        sessionScores["stress"]!.add((scores["scoreStress"] ?? 0).toDouble());

        // Mood:value
        sessionMoods.add((mood["value"] ?? 0).toDouble());

        // Número de flags
        sessionFlagCounts.add(flags.length.toDouble());
      }

      // 4) Generar FlSpots y actualizar el estado
      setState(() {
        depressionData = List.generate(
          sessionScores["depression"]!.length,
          (i) => FlSpot(i.toDouble(), sessionScores["depression"]![i]),
        );
        anxietyData = List.generate(
          sessionScores["anxiety"]!.length,
          (i) => FlSpot(i.toDouble(), sessionScores["anxiety"]![i]),
        );
        stressData = List.generate(
          sessionScores["stress"]!.length,
          (i) => FlSpot(i.toDouble(), sessionScores["stress"]![i]),
        );
        moodData = List.generate(
          sessionMoods.length,
          (i) => FlSpot(i.toDouble(), sessionMoods[i]),
        );
        flagCountData = List.generate(
          sessionFlagCounts.length,
          (i) => FlSpot(i.toDouble(), sessionFlagCounts[i]),
        );
      });
    } catch (e) {
      print("❌ Error al obtener sesiones: $e");
    }
  }

  /// Construye una gráfica de línea con título [title], puntos [data] y color [color].
  Widget _buildChart(String title, List<FlSpot> data, Color color) {
    final maxX = data.isNotEmpty ? data.length - 1.0 : 0.0;
    final maxY = data.isNotEmpty
        ? data.map((s) => s.y).reduce((a, b) => a > b ? a : b)
        : 0.0;

    // <-- evito intervalo 0
    final yInterval = maxY > 0 ? maxY / 4 : 1.0;

    return Card(
      color: Colors.white.withOpacity(0.2),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval, // nunca 0
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i > maxX) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text('S${i + 1}',
                                style: TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                          show: true, color: color.withOpacity(0.3)),
                      dotData: FlDotData(show: true),
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

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          // Contenedor para el AppBar con fondo con imagen
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            title: Text("Weekly Progress"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: colorScheme.primaryContainer,
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildChart(
                    "Depresión (DASS21)", depressionData, Colors.redAccent),
                _buildChart(
                    "Ansiedad (DASS21)", anxietyData, Colors.orangeAccent),
                _buildChart("Estrés (DASS21)", stressData, Colors.blueAccent),
                _buildChart(
                    "Mood Level", moodData, Colors.purpleAccent), // ← NUEVO
                _buildChart("Flags Detected", flagCountData,
                    Colors.greenAccent), // ← NUEVO
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        // Botón flotante recomendaciones
        padding: const EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendationPage(
                      depressionScore: 0,
                      anxietyScore: 0,
                      stressScore: 0,
                    ),
                  ),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              tooltip: 'Check out the recommendations!',
              child: const Icon(Icons.dataset_outlined),
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LLMRecommendationPage(
                      depressionScore: 0,
                      anxietyScore: 0,
                      stressScore: 0,
                    ),
                  ),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              tooltip: 'Check out the IA recommendations!',
              child: const Icon(Icons.memory_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
