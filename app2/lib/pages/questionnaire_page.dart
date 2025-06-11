import 'dart:convert';
import 'package:app2/models/session_data.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart'; // Importa Provider para manejar el estado para sessionRef
import 'package:app2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app2/models/question.dart';
import 'recommendations/recommendation_page.dart';
import 'recommendations/llmrecommend_page.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentIndex = 0; // Índice de la pregunta actual
  String? _selectedOption; // Opción respuesta seleccionada

  List<Question> _questions = []; // Lista de preguntas
  int _scoreDepression = 0; // Puntuación total de depresión
  int _scoreAnxiety = 0; // Puntuación total de ansiedad
  int _scoreStress = 0; // Puntuación total de estrés
  bool _isCompleted = false; // Indica si el cuestionario ha terminado

  @override
  // Inicializa el estado del widget o pagina directamente
  void initState() {
    super.initState();
    _loadQuestionsFromJson();
  }

  Future<void> _loadQuestionsFromJson() async {
    try {
      // Carga el archivo JSON desde assets
      String jsonString = await rootBundle.loadString('assets/questions.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      // Convierte la lista de preguntas del JSON a objetos Question
      List<Question> questions = (jsonData["preguntas"] as List)
          .map((data) => Question.fromJson(data))
          .toList();

      // Actualiza el estado con las preguntas cargadas
      setState(() {
        _questions = questions;
      });

      print("📌 Preguntas cargadas: ${_questions.length}");
    } catch (e) {
      print("❌ Error al cargar preguntas desde JSON: $e");
    }
  }

  // Guarda la respuesta en Firebase
  void _saveResponse(Question pregunta, String respuesta) {
    // Acumula en la categoria correspondiente la puntuación
    final score = _getScore(respuesta);

    // Acumula en la categoría correspondiente
    switch (pregunta.category) {
      case "depression":
        _scoreDepression += score;
        break;
      case "anxiety":
        _scoreAnxiety += score;
        break;
      case "stress":
        _scoreStress += score;
        break;
    }

    print("📌 Respuesta: $respuesta");
    print("🥇 Puntuación: $score");
    print("📈Puntaje depresión: $_scoreDepression");
    print("📈Puntaje ansiedad: $_scoreAnxiety");
    print("📈Puntaje estrés: $_scoreStress");
  }

  int _getScore(String respuesta) {
    if (respuesta == "Did not apply to me at all") {
      return 0; // No aplica, no suma puntos
    } else if (respuesta ==
        "Applied to me to some degree, or some of the time") {
      return 1; // Aplica un poco, suma 1 punto
    } else if (respuesta ==
        "Applied to me to a considerable degree or a good part of time") {
      return 2; // Aplica moderadamente, suma 2 puntos
    } else if (respuesta == "Applied to me very much or most of the time") {
      return 3; // Aplica mucho, suma 3 puntos
    }
    return 0; // Valor por defecto si no coincide ninguna opción
  }

  // Guarda los puntajes finales en Firebase
  Future<void> _saveFinalScores() async {
    // Referencia a la sesión actual
    final sessionRef = context.read<MyAppState>().sessionRef;
    //Obtener ID de sesión para Hive
    final sid = context.read<MyAppState>().sessionRef?.id;
    if (sessionRef != null) {
      // Actualizar Firestore
      await sessionRef.update({
        "scores": {
          "scoreDepression": _scoreDepression,
          "scoreAnxiety": _scoreAnxiety,
          "scoreStress": _scoreStress,
        },
        'timestamp': FieldValue.serverTimestamp(), // Actualiza el timestamp
      });
      // Actualizar Hive local
      var box = Hive.box<SessionData>('sessionsBox');
      final local = box.get(sid); // Obtiene la sesión local
      if (local != null) {
        local.scores = Scores(
          scoreDepression: _scoreDepression,
          scoreAnxiety: _scoreAnxiety,
          scoreStress: _scoreStress,
        );
        local.timestamp = DateTime.now();
        await local.save(); // HiveObject: guarda cambios
      } else {
        // Si no existe, creamos sessionData y guardamos:
        final sessionData = SessionData(
          timestamp: DateTime.now(),
          scores: Scores(
            scoreDepression: _scoreDepression,
            scoreAnxiety: _scoreAnxiety,
            scoreStress: _scoreStress,
          ),
        );
        await box.put(sid, sessionData);
      }
    } else {
      print("No hay sessionRef para guardar scores");
    }
    return;
  }

// Método para avanzar a la siguiente pregunta
  void _nextQuestion() {
    if (_selectedOption != null) {
      _saveResponse(_questions[_currentIndex], _selectedOption!);
    }
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null; // Reset opción seleccionada
      });
    } else {
      // Última pregunta: guardamos resultados y mostramos botones
      _saveFinalScores().then((_) {
        print("✅ Resultados finales guardados en Firebase");
        print("📈Puntaje depresión: $_scoreDepression");
        print("📈Puntaje ansiedad: $_scoreAnxiety");
        print("📈Puntaje estrés: $_scoreStress");
      }).catchError((e) {
        print("❌ Error guardando resumen: $e");
      });
      setState(() {
        _isCompleted = true; // Marcar el cuestionario como finalizado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Cuestionario"),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primaryContainer),
        ),
        body: Center(child: CircularProgressIndicator()), // Spinner de carga
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          // Ponemos la imagen de fondo aquí
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            title: Text("Questionnaire"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ),
      ),
      //backgroundColor: const Color.fromARGB(255, 0, 15, 49),
      body: SizedBox.expand(
        //Fondo pantalla
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: _isCompleted
                // Si ha terminado el cuestionario => Pantalla final
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Cuestionario terminado con exito!!",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecommendationPage(
                                      depressionScore: _scoreDepression,
                                      anxietyScore: _scoreAnxiety,
                                      stressScore: _scoreStress,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Ver recomendaciones con respuesta mecánica",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(width: 20), // espacio entre botones
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LLMRecommendationPage(
                                      depressionScore: _scoreDepression,
                                      anxietyScore: _scoreAnxiety,
                                      stressScore: _scoreStress,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Ver recomendaciones con respuesta IA",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Regresar a GeneratorPage
                            setState(() {
                              _isCompleted = false;
                              //_currentQuestionIndex = 0;
                              _scoreDepression = 0;
                              _scoreAnxiety = 0;
                              _scoreStress = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.deepPurple.shade200.withOpacity(0.8),
                          ),
                          child: Text("Volver a la página principal",
                              style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ],
                    ),
                  )

                // Si no ha terminado el cuestionario
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Widget BigCard que muestra la pregunta actual
                      Center(
                        child: BigCard(
                            question: _questions[_currentIndex].pregunta),
                      ),

                      SizedBox(height: 20),

                      // Opciones con botones de radio
                      ..._questions[_currentIndex].opciones.map((opcion) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // sólo el ancho necesario
                            mainAxisAlignment:
                                MainAxisAlignment.center, // centra la fila
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Radio<String>(
                                value: opcion,
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                  });
                                },
                              ),
                              SizedBox(
                                  width: 12), // espacio entre radio y texto
                              Text(
                                opcion,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            _selectedOption != null ? _nextQuestion : null,
                        child: Text(
                          _currentIndex < _questions.length - 1
                              ? "Siguiente"
                              : "Finalizar",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final String question; // Pregunta: _questions[_currentIndex].pregunta

  const BigCard({
    //constructor
    Key? key,
    required this.question, // Parámetro (pregunta) obligatorio
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Theme.of(context).colorScheme.primary,
      color: Colors.deepPurple.shade200.withOpacity(0.8),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          question,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
