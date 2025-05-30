import "package:app2/main.dart";
import "package:app2/pages/carrusel/carruselFeelGood_page.dart";
import "package:app2/pages/carrusel/carruselFocus_page.dart";
import "package:app2/pages/carrusel/carruselRelax_page.dart";
import "package:app2/pages/carrusel/carruselSleep_page.dart";
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import "package:app2/pages/questionnaire_page.dart";

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 0, 29, 49),
      // Widget: SizedBox : Ocupa todo el espacio disponible
      // Widget Container : permite superponer widgets: imagen fonfo + contenido encima
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 20),
                    MoodTracker(),
                    SizedBox(height: 20),
                    _CarouselCard(context),
                    SizedBox(height: 60),
                    _cuestionarioSemanal(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader() {
  //Cabecera de Home
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("¡Hola de nuevo!",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/users/user_avatar.png'),
          ),
        ],
      ),
    ],
  );
}

//-----------------Mood Tracker (barra emociones)-----------------
class MoodTracker extends StatefulWidget {
  @override
  _MoodTrackerState createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  double moodLevel = 0.7; // Nivel inicial (0.0 - Bajo, 1.0 - Alto)
  final double barWidth = 300; // Ancho de la barra

  @override
  Widget build(BuildContext context) {
    MoodStatus moodStatus = _getMoodStatus(moodLevel); // Estado de ánimo actual

    return Column(
      children: [
        Text(
          "Mood Level",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),

        // ---- Barra de emociones y botón juntos ----
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Barra interactiva
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
                      borderRadius:
                          BorderRadius.circular(10), //redondear bordes
                      gradient: LinearGradient(
                        //colores de la barra
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.deepPurple.shade200,
                          Theme.of(context).colorScheme.onPrimary,
                        ],
                        stops: [0.0, 0.5, 1.0], //posición de los colores
                      ),
                    ),
                  ),
                  // Indicador del estado de ánimo (icono que se mueve)
                  Positioned(
                    left: moodLevel *
                        (barWidth - 24), // Ajuste del icono en la barra
                    child: Icon(moodStatus.icon, color: Colors.black, size: 24),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12),

            // Botón para guardar estado de ánimo
            IconButton(
              icon: Icon(Icons.radio_button_checked,
                  color: Colors.white, size: 30),
              splashRadius: 50, // tamaño del spash
              splashColor: Colors.white.withOpacity(0.9),
              highlightColor: Colors.white.withOpacity(0.2),
              tooltip: 'Guardar tu estado de ánimo',
              onPressed: () async {
                // Guarda mood + valor + timestamp en Firestore
                await FirebaseFirestore.instance.collection('moods').add({
                  'mood': moodStatus.label,
                  'value': moodLevel,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                // Muestra un mensaje emergente de confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:
                        Colors.deepPurple.shade200.withOpacity(0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: Duration(milliseconds: 400),
                    content: Center(
                      child: Text(
                        'Tu estado "${moodStatus.label}" ha sido guardado',
                        style: TextStyle(
                          color: Colors.grey.shade200,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        SizedBox(height: 10),

        // Mantenemos solo el texto de Status abajo
        Text(
          "Status: ${moodStatus.label}",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }

  // Obtener el estado de ánimo basado en el nivel
  MoodStatus _getMoodStatus(double level) {
    if (level < 0.20)
      return MoodStatus("Bad", Icons.sentiment_very_dissatisfied);
    if (level < 0.40)
      return MoodStatus("Stressed", Icons.sentiment_dissatisfied);
    if (level < 0.55) return MoodStatus("Normal", Icons.sentiment_neutral);
    if (level < 0.70) return MoodStatus("Good", Icons.sentiment_satisfied);
    if (level < 0.85)
      return MoodStatus("Very Good", Icons.sentiment_very_satisfied);
    return MoodStatus("Excellent", Icons.emoji_emotions);
  }
}

class MoodStatus {
  final String label;
  final IconData icon;

  MoodStatus(this.label, this.icon);
}

//-----------------CarouselCard-----------------
Widget _CarouselCard(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: CardInfo.values.map((CardInfo info) {
            //Widget MouseRegion: Detecta el cursor del ratón
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  switch (info) {
                    case CardInfo.relax:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CarruselrelaxPage())); // Redirige a carruselRelax
                      print('Has pulsado la tarjeta ${info.label}');
                      return;
                    case CardInfo.focus:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CarruselfocusPage())); // Redirige a carruselFocus
                      print('Has pulsado la tarjeta ${info.label}');
                      return;
                    case CardInfo.sleep:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CarruselsleepPage())); // Redirige a carruselSleep
                      print('Has pulsado la tarjeta ${info.label}');
                      return;
                    case CardInfo.feelGood:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CarruselfeelgoodPage())); // Redirige a carruselFeelGood
                      print('Has pulsado la tarjeta ${info.label}');
                      return;
                  }
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(info.backgroundImage),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(info.icon, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text(
                          info.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.clip,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

//Diseño de cada tarjeta del carousel
enum CardInfo {
  relax('Relax', Icons.self_improvement_rounded, 'assets/images/image2.jpg'),
  focus('Focus', Icons.lightbulb, 'assets/images/image2.jpg'),
  sleep('Sleep', Icons.nightlight_round_outlined, 'assets/images/image2.jpg'),
  feelGood('Feel Good', Icons.sentiment_very_satisfied_rounded,
      'assets/images/image2.jpg'),
  //media('Media', Icons.library_music, 'assets/images/image5.jpg'),
  more('', Icons.add, 'assets/images/image2.jpg');

  const CardInfo(this.label, this.icon, this.backgroundImage);
  final String label;
  final IconData icon;
  final String backgroundImage;
}

//-----------------Cuestionario Semanal-----------------
Widget _cuestionarioSemanal(BuildContext context) {
  //Widget MouseRegion: Detecta el cursor del ratón
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      // Permite detectar gestos en el widget
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  QuestionPage()), // Redirige a la página del cuestionario
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade200.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text("Weekly Questionnaire",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 5),
            Text("Realiza tu seguimiento psicológico",
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    ),
  );
}
