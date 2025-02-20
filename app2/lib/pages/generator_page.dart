import "package:app2/main.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:app2/pages/questionnaire_page.dart";

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 15, 49),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildMoodTracker(),
              SizedBox(height: 20),
              _CarouselCard(),
              //_buildRecommendationCards(),
              SizedBox(height: 60),
              _buildWeeklySurveyCard(context),
            ],
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
          Text("Bienvenido, Usuario!",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/user_avatar.png'),
          ),
        ],
      ),
    ],
  );
}

Widget _buildMoodTracker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("¿Cómo te sientes hoy?",
          style: TextStyle(fontSize: 18, color: Colors.white)),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMoodIcon(Icons.sentiment_very_satisfied, "Feliz"),
          _buildMoodIcon(Icons.sentiment_neutral, "Normal"),
          _buildMoodIcon(Icons.sentiment_dissatisfied, "Triste"),
        ],
      )
    ],
  );
}

Widget _buildMoodIcon(IconData icon, String mood) {
  return Column(
    children: [
      Icon(icon, size: 40, color: Colors.white),
      SizedBox(height: 5),
      Text(mood, style: TextStyle(color: Colors.white)),
    ],
  );
}

//-----------------CarouselCard-----------------

Widget _CarouselCard() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: CardInfo.values.map((CardInfo info) {
            return Container(
              width: 150,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(info.backgroundImage),
                  fit:
                      BoxFit.cover, // Ajustar la imagen al tamaño de la tarjeta
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
            );
          }).toList(),
        ),
      ),
    ],
  );
}

enum CardInfo {
  camera('Relax', Icons.video_call, 'assets/images/image1.jpg'),
  lighting('Focus', Icons.lightbulb, 'assets/images/image2.jpg'),
  climate('Sleep', Icons.thermostat, 'assets/images/image3.jpg'),
  wifi('Feel Good', Icons.wifi, 'assets/images/image4.jpg'),
  media('Media', Icons.library_music, 'assets/images/image5.jpg'),
  more('', Icons.add, 'assets/images/image6.jpg');

  const CardInfo(this.label, this.icon, this.backgroundImage);
  final String label;
  final IconData icon;
  final String backgroundImage;
}

//-------------------------------------
/*
Widget _buildRecommendationCards() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Recomendaciones",
          style: TextStyle(fontSize: 18, color: Colors.white)),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryCard("Relax", Icons.spa, Colors.blue),
          _buildCategoryCard("Focus", Icons.center_focus_strong, Colors.purple),
        ],
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryCard("Sleep", Icons.nightlight_round, Colors.green),
          _buildCategoryCard("Feel Good", Icons.favorite, Colors.red),
        ],
      )
    ],
  );
}


Widget _buildCategoryCard(String title, IconData icon, Color color) {
  //StreamBuilder
  return Container(
    width: 150,
    height: 120,
    decoration: BoxDecoration(
      color: color.withOpacity(0.7),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: Colors.white),
        SizedBox(height: 5),
        Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
*/

Widget _buildWeeklySurveyCard(BuildContext context) {
  return GestureDetector(
    // Permite detectar gestos en el widget
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuestionPage()),
      );
    }, // Implementar navegación al cuestionario
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text("Cuestionario semanal",
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
  );
}
