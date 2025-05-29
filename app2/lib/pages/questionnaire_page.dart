import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app2/models/question.dart';
import 'recommendation_page.dart';
import 'llmrecommend_page.dart';

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
  int _scoreLoneliness = 0; // Puntuación total de soledad
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
    final score = _getScore(pregunta, respuesta);

    // Acumula en la categoría correspondiente
    switch (pregunta.category) {
      case "depression":
        _scoreDepression += score;
        break;
      case "anxiety":
        _scoreAnxiety += score;
        break;
      case "loneliness":
        _scoreLoneliness += score;
        break;
    }

    print("📌 Respuesta: $respuesta");
    print("🥇 Puntuación: $score");
    print("📈Puntaje depresión: $_scoreDepression");
    print("📈Puntaje ansiedad: $_scoreAnxiety");
    print("📈Puntaje soledad: $_scoreLoneliness");
  }

  int _getScore(Question pregunta, String respuesta) {
    switch (pregunta.category) {
      case "depression":
        switch (respuesta) {
          case "Nunca":
            return 0;
          case "Rara vez":
            return 1;
          case "A veces":
            return 2;
          case "Casi siempre":
            return 3;
        }
        break;
      case "anxiety":
        switch (respuesta) {
          case "Nunca":
            return 0;
          case "Ninguna":
            return 1;
          case "A veces":
            return 1;
          case "Pocas":
            return 1;
          case "Frecuentemente":
            return 2;
          case "Algunas":
            return 2;
          case "Casi siempre":
            return 3;
          case "Sí, muchas":
            return 3;
        }
        break;
      case "loneliness":
        switch (respuesta) {
          case "Casi nunca":
            return 0;
          case "Frecuentemente":
            return 0;
          case "Siempre":
            return 0;
          case "Algunas veces":
            return 1;
          case "A veces":
            return 1;
          case "Rara vez":
            return 2;
          case "A menudo":
            return 3;
          case "Nunca":
            return 3;
        }
        break;
    }
    return 0;
  }

  // Guarda los puntajes finales en Firebase
  Future<void> _saveFinalScores() {
    return FirebaseFirestore.instance
        .collection("resultados") // o "respuestas_resumen"
        .add({
      "scoreDepression": _scoreDepression,
      "scoreAnxiety": _scoreAnxiety,
      "scoreLoneliness": _scoreLoneliness,
      "timestamp": FieldValue.serverTimestamp(),
    });
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
        print("📈Puntaje soledad: $_scoreLoneliness");
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
        ),
        body: Center(child: CircularProgressIndicator()), // Spinner de carga
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Cuestionario"),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primaryContainer),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 15, 49),
      body: Padding(
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
                                  lonelinessScore: _scoreLoneliness,
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
                                  lonelinessScore: _scoreLoneliness,
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
                          _scoreLoneliness = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepPurple.shade200.withOpacity(0.8),
                      ),
                      child: Text("Volver a la página principal",
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onPrimary)),
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
                    child:
                        BigCard(question: _questions[_currentIndex].pregunta),
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
                          SizedBox(width: 12), // espacio entre radio y texto
                          Text(
                            opcion,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedOption != null ? _nextQuestion : null,
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
      //color: Colors.deepPurple.shade200,
      color: Theme.of(context).colorScheme.primary,

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
