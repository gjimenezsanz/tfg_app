import "package:app2/main.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: AlertButtom()),
      ),
    );
  }
}

class AlertButtom extends StatelessWidget {
  const AlertButtom({super.key});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        barrierDismissible:
            false, // No permite cerrar la alerta al tocar fuera de él
        builder: (BuildContext context) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          backgroundColor: Colors.deepPurple.shade200.withOpacity(0.6),
          //backgroundColor: Colors.white.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'User Data Privacy',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            16, // left
            8, // top
            16, // right
            8, // bottom
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/privacity.png', height: 170, width: 170),
              const SizedBox(height: 8),
              // Envolvemos el texto en un Container para limitar el ancho
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Opcional: limitar ancho máximo:
                constraints: BoxConstraints(maxWidth: 300),
                child: const Text(
                  'Data collected from users of this application will be used for analysis and research purposes to improve the application in future.\n\n'
                  'We will not share your data with third parties without your consent.\n\n'
                  'Do you consent to this data being disclosed?.',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),

      // Botón que muestra la alerta
      child: const Text('User Data Privacy Alert'),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        textStyle: TextStyle(fontSize: 15),
      ),
    );
  }
}
