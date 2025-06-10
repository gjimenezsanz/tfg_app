import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  final int depressionScore;
  final int anxietyScore;
  final int lonelinessScore;

  RecommendationPage({
    required this.depressionScore,
    required this.anxietyScore,
    required this.lonelinessScore,
  });

  // Respuesta según la puntuación del parámetro de depresión
  String getDepressionRecommendation() {
    if (depressionScore <= 5) {
      return "Tu nivel de síntomas depresivos es bajo. Continúa con actividades que te generen bienestar emocional y mantén un estilo de vida saludable.";
    } else if (depressionScore <= 10) {
      return "Tu nivel de síntomas depresivos es moderado. Podría ser útil hablar con alguien de confianza o un profesional si sientes que estos síntomas afectan tu vida diaria.";
    } else {
      return "Tu nivel de síntomas depresivos es alto. Se recomienda buscar apoyo profesional y rodearte de personas que puedan brindarte apoyo emocional.";
    }
  }

  // Respuesta según la puntuación del parámetro de ansiedad
  String getAnxietyRecommendation() {
    if (anxietyScore <= 5) {
      return "Tu nivel de ansiedad es bajo. Sigue manteniendo una buena gestión del estrés y busca momentos para relajarte.";
    } else if (anxietyScore <= 10) {
      return "Tu nivel de ansiedad es moderado. Intenta practicar técnicas de relajación como la respiración profunda o la meditación.";
    } else {
      return "Tu nivel de ansiedad es alto. Sería recomendable buscar ayuda profesional para aprender estrategias de manejo del estrés y la ansiedad.";
    }
  }

  // Respuesta según la puntuación del parámetro de soledad
  String getLonelinessRecommendation() {
    if (lonelinessScore <= 3) {
      return "Tu nivel de aislamiento social es bajo. Sigue manteniendo una vida social activa y apóyate en tus seres queridos.";
    } else if (lonelinessScore <= 6) {
      return "Tu nivel de aislamiento es moderado. Intenta mantener más contacto con amigos y familiares. Participar en actividades grupales puede ayudarte.";
    } else {
      return "Tu nivel de aislamiento es alto. Podría ser útil hablar con alguien de confianza o un profesional. Considera unirte a comunidades o buscar apoyo.";
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text("Recommendations"),
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
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Resultados del cuestionario",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Depresión:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Tu depresión tiene una puntuación de: $depressionScore",
                  style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  getDepressionRecommendation(),
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Ansiedad:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Tu ansiedad tiene una puntuación de: $anxietyScore",
                  style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  getAnxietyRecommendation(),
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Soledad y Aislamiento Social:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Tu soledad tiene una puntuación de: $lonelinessScore",
                  style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  getLonelinessRecommendation(),
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple.shade200.withOpacity(0.8),
                  ),
                  child: Text(
                    "Volver",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
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
