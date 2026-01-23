import 'package:flutter/material.dart';

class RecommendationPage extends StatelessWidget {
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;

  RecommendationPage({
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
  });

  // Respuesta según la puntuación del parámetro de depresión
  String getDepressionRecommendation() {
    if (depressionScore <= 7) {
      return "Your level of depressive symptoms is low. Continue with activities that bring you emotional well-being, and maintain a healthy lifestyle.";
    } else if (depressionScore <= 14) {
      return "Your level of depressive symptoms is moderate. It might be helpful to talk to someone you trust or a professional if you feel these symptoms are affecting your life routine.";
    } else {
      return "Your level of depressive symptoms is high. It is recommended to seek professional support and surround yourself with people who can provide emotional support.";
    }
  }

  // Respuesta según la puntuación del parámetro de ansiedad
  String getAnxietyRecommendation() {
    if (anxietyScore <= 7) {
      return "Your anxiety level is low. Continue to manage your stress well and find moments to relax.";
    } else if (anxietyScore <= 14) {
      return "Your anxiety level is moderate. Try practicing relaxation techniques like deep breathing or meditation.";
    } else {
      return "Your anxiety level is high. It would be recommended to seek professional help to learn stress and anxiety management strategies.";
    }
  }

  // Respuesta según la puntuación del parámetro de estrés
  String getStressRecommendation() {
    if (stressScore <= 7) {
      return "Your stress level is low. Try relaxation techniques and deep breathing that help maintain calm.";
    } else if (stressScore <= 14) {
      return "Your stress level is moderate. Integrate active pauses and brief mindfulness sessions into your daily routine to relieve tension.";
    } else {
      return "Your stress level is high. Seek professional support and establish a daily self-care habit with meditation and adequate rest.";
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
                  "Questionnaire results",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Depression:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Your depression score is: $depressionScore",
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
                  "Anxiety:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Your anxiety score is: $anxietyScore",
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
                  "Stress:",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Your stress score is: $stressScore",
                  style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primaryContainer),
                  textAlign: TextAlign.center,
                ),
                Text(
                  getStressRecommendation(),
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
                    "Back",
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
