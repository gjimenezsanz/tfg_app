import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[]; //solo puede ser de tipo WordPair, no null

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners(); //avisa del cambiod e estado
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //clase estado

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        //page = Placeholder(); //pantalla por defecto
        page = FavoritesPage();
        break;
      default: //para que no salga nada de error si no se pulsa uno de los otros
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      //modifica el tamaño del widget en funcion del espacio de la pantalla
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                //menu de navegación
                extended:
                    constraints.maxWidth >= 600, //se ven las palabras e iconos
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex, //home
                onDestinationSelected: (value) {
                  setState(() {
                    //clase que notifica del cambio de estado
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              // widgets expandidos
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current; //pares palabras

    IconData icon;
    if (appState.favorites.contains(pair)) {
      //lista de favoritos
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      //Centrar columna al medio
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, //centrar texto al medio en horizontal
        children: [
          BigCard(pair: pair), //pares palabras en minisculas
          SizedBox(height: 10), //crea espacio visual
          Row(
            //Equivalente horizontal de colum
            mainAxisSize: MainAxisSize.min, //centrar texto al medio en vertical
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),

              SizedBox(width: 10), //crea espacio visual

              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, //color más acorde
    );
    return Card(
      color: theme.colorScheme.primary, //primary color mas destacado
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel:
              "${pair.first} ${pair.second}", //para diferenciar palabras por accesibilidad
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites; //lista favoritos

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      //listado en columna
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${favorites.length} favorites:'),
        ),
        for (var favorite in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite), //para iconos
            title: Text(favorite.asLowerCase), //para texto
          ),
      ],
    );
  }
}
