import 'package:app2/pages/home_page.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para usar Firestore
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'firebase_options.dart'; // Archivo generado por flutterfire configure

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que los widgets estén inicializados antes de ejecutar el código
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            // Configuración para la web
            apiKey: "AIzaSyAQjZJnY-Gv0MrAXH9fBClyeOI5CsZfZTo",
            authDomain: "fir-flutter-ac78a.firebaseapp.com",
            projectId: "fir-flutter-ac78a",
            storageBucket: "fir-flutter-ac78a.firebasestorage.app",
            messagingSenderId: "385148574959",
            appId: "1:385148574959:web:51e262871cd0db658a8f1a"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Para usar colorScheme en appBarTheme y radioTheme sin depender de Theme.of(context)
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 29, 20, 127),
    );
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            // Color de la flecha “back”
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          // Color botones cuestinarios
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primaryContainer;
              }
              return Colors.white70;
            }),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() {
    _initSession();
  }
  DocumentReference? _sessionRef;
  // Getter para acceder a la referencia de sesión
  DocumentReference? get sessionRef => _sessionRef;

  Future<void> _initSession() async {
    try {
      // Generar un ID de sesión basado en timestamp al arrancar la app
      final sid = DateTime.now().millisecondsSinceEpoch.toString();
      final docRef = FirebaseFirestore.instance.collection('sessions').doc(sid);
      _sessionRef = docRef;
      // Crear el documento con campo timestamp inicial
      await docRef.set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Sesión iniciada con ID: $sid');
      notifyListeners();
    } catch (e) {
      print('Error creando sesión inicial en Firestore: $e');
    }
  }

  // Método para limpiar
  void clearSessionRef() {
    _sessionRef = null;
    notifyListeners();
  }

  var current = WordPair.random(); //inicializa con un par aleatorio
  var history = <WordPair>[]; //lista historial

  GlobalKey? historyListKey; //accede al estado de un widget especifico

  void getNext() {
    //boton next
    history.insert(0, current); //añade al principio de la lista history el pair
    var animatedList = historyListKey?.currentState
        as AnimatedListState?; //obtiene el estado del widget AnimatedList y lo convierte en un AnimatedListState
    animatedList
        ?.insertItem(0); //añade un nuevo elemento en la lista con animacion
    current = WordPair.random();
    notifyListeners();
  }

  var favorites =
      <WordPair>[]; //lista favoritos, solo puede ser de tipo WordPair, no null

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current; //si pair es null, se le asigna current
    //boton like
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners(); //avisa del cambio de estado
  }

  void removeFavorite(WordPair pair) {
    //boton remove
    favorites.remove(pair);
    notifyListeners();
  }
}
