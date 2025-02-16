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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //clase estado, varia de una pantalla a otra

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
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

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            //se ven solo iconos
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex, //home
                    onTap: (value) {
                      setState(() {
                        //clase que notifica del cambio de estado
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            //para pantallas más grandes
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    //menu de navegación
                    extended: constraints.maxWidth >=
                        600, //se ven las palabras e iconos
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
                Expanded(child: mainArea), //widget expandido
              ],
            );
          }
        },
      ),
    );
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
          Expanded(
            //widget expandido
            flex: 3, //espacio entre botones y arriba
            child: HistoryListView(), //historial de palabras
          ),
          SizedBox(height: 10), //crea espacio visual
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
          Spacer(flex: 2) //espacio entre botones y abajo
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key, //clave única, puede ser null
    required this.pair,
  }) : super(key: key);

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
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          // Make sure that the compound word wraps correctly when the window
          // is too narrow.
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first, //primera palabra
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second, //segunda palabra
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites; //lista favoritos

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline,
                        semanticLabel: 'Delete'), //para icono
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text(
                    //para texto
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  //clase estado, varian las palabras en la pantalla
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    //para hacer un degradado, desvanecer los elementos
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter, //trasparente arriba
    end: Alignment.bottomCenter, //opaco abajo
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn, //aplica el gradiente a la lista
      child: AnimatedList(
        key: _key,
        reverse: true, //lista al revés
        padding: EdgeInsets.only(top: 100), //espacio arriba para lista
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          //para cada item o elemento
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation, //animar la transición
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(
                      pair); // Asegúrate de pasar el par correcto
                },
                icon: appState.favorites.contains(pair) //para el icono si like
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(), //si no hay like, espacio vacio
                label: Text(
                  //para la palabra
                  //para texto
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
