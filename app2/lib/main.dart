import 'package:app2/pages/home_page.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Archivo generado por flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
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
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 29, 20, 127)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[]; //lista historial

  GlobalKey?
      historyListKey; //accede al estado de un widget especifico, puede ser null

  void getNext() {
    //boton next
    history.insert(0, current); //añade al principio de la lista history el pair
    var animatedList = historyListKey?.currentState
        as AnimatedListState?; //obtiene el estado del widget AnimatedList y lo convierte en un AnimatedListState, puede ser null
    animatedList?.insertItem(
        0); //añade un nuevo elemento en la lista con animacion, puede ser null
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
