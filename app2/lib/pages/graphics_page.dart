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
  List<FlSpot> lonelinessData = [];

  @override
  void initState() {
    super.initState();
    _fetchWeeklyData();
  }

  Future<void> _fetchWeeklyData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("respuestas")
          .orderBy("timestamp", descending: true)
          .get();

      Map<String, List<int>> weeklyScores = {
        "depression": List.filled(5, 0),
        "anxiety": List.filled(5, 0),
        "loneliness": List.filled(5, 0)
      };

      Map<String, List<int>> weeklyCounts = {
        "depression": List.filled(5, 0),
        "anxiety": List.filled(5, 0),
        "loneliness": List.filled(5, 0)
      };

      DateTime now = DateTime.now();
      for (var doc in snapshot.docs) {
        DateTime timestamp = (doc["timestamp"] as Timestamp).toDate();
        int weekDiff = now.difference(timestamp).inDays ~/ 7;

        if (weekDiff < 5) {
          String pregunta = doc["pregunta"];
          var data = doc.data() as Map<String, dynamic>;
          int score = data.containsKey("puntaje") ? data["puntaje"] : 0;

          if (pregunta.contains("tristeza") ||
              pregunta.contains("desesperanza") ||
              pregunta.contains("placer") ||
              pregunta.contains("culpable")) {
            weeklyScores["depression"]![weekDiff] += score;
            weeklyCounts["depression"]![weekDiff] += 1;
          } else if (pregunta.contains("ansiedad") ||
              pregunta.contains("preocupaciones") ||
              pregunta.contains("ritmo cardíaco")) {
            weeklyScores["anxiety"]![weekDiff] += score;
            weeklyCounts["anxiety"]![weekDiff] += 1;
          } else {
            weeklyScores["loneliness"]![weekDiff] += score;
            weeklyCounts["loneliness"]![weekDiff] += 1;
          }
        }
      }

      setState(() {
        depressionData = _calculateWeeklyAverage(
            weeklyScores["depression"]!, weeklyCounts["depression"]!);
        anxietyData = _calculateWeeklyAverage(
            weeklyScores["anxiety"]!, weeklyCounts["anxiety"]!);
        lonelinessData = _calculateWeeklyAverage(
            weeklyScores["loneliness"]!, weeklyCounts["loneliness"]!);
      });
    } catch (e) {
      print("❌ Error al obtener datos: $e");
    }
  }

  List<FlSpot> _calculateWeeklyAverage(List<int> scores, List<int> counts) {
    List<FlSpot> data = [];
    for (int i = 0; i < scores.length; i++) {
      double average = counts[i] > 0 ? scores[i] / counts[i] : 0;
      data.add(FlSpot(i.toDouble(), average));
    }
    return data;
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color) {
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
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text("Semana ${(value + 1).toInt()}",
                              style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
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
            )
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
              color: Theme.of(context).colorScheme.primaryContainer,
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
                    "Depresión (BDI-II)", depressionData, Colors.redAccent),
                _buildChart("Ansiedad (BSI)", anxietyData, Colors.orangeAccent),
                _buildChart("Soledad (UCLA Loneliness Scale)", lonelinessData,
                    Colors.blueAccent),
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
            Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Redirige a la página RecommendationPage usando Navigator
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendationPage(
                          depressionScore: 0,
                          anxietyScore: 0,
                          lonelinessScore: 0,
                        ),
                      ),
                    );
                  },
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: const CircleBorder(),
                  tooltip: 'Check out the recommendations!',
                  child: const Icon(Icons.dataset_outlined),
                ),
                SizedBox(height: 10), // Espaciado entre botones
                FloatingActionButton(
                  onPressed: () {
                    // Redirige a la página LLMRecommendationPage usando Navigator
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LLMRecommendationPage(
                          depressionScore: 0,
                          anxietyScore: 0,
                          lonelinessScore: 0,
                        ),
                      ),
                    );
                  },
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: const CircleBorder(),
                  tooltip: 'Check out the IA recommendations!',
                  child: const Icon(Icons.memory_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
