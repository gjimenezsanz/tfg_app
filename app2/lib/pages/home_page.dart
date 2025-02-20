import "package:app2/pages/chat_page.dart";
import "package:app2/pages/favorites_page.dart";
import "package:app2/pages/generator_page.dart";
import "package:app2/pages/user_page.dart";
import "package:flutter/material.dart";

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
      case 2:
        //page = Placeholder(); //pantalla por defecto
        page = UserPage();
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
        //widgets que dependen del tamaño de la pantalla
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
                        icon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.stacked_bar_chart),
                        label: 'Statics',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_rounded),
                        label: 'User',
                      ),
                    ],
                    backgroundColor: Colors.black,
                    selectedIconTheme: IconThemeData(color: Colors.white),
                    unselectedIconTheme: IconThemeData(color: Colors.grey),
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
                        icon: Icon(Icons.home_rounded),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.stacked_bar_chart),
                        label: Text('Statics'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_rounded),
                        label: Text('User'),
                      ),
                    ],
                    backgroundColor: Colors.black,
                    selectedIconTheme: IconThemeData(color: Colors.black),
                    unselectedIconTheme: IconThemeData(color: Colors.grey),
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
      floatingActionButton: Padding(
        //boton flotante chat
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                // Redirige a la página ChatPage usando Navigator
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
              backgroundColor: Colors.cyan.shade600,
              foregroundColor: colorScheme.onPrimary,
              shape: const CircleBorder(),
              tooltip: 'Chat with me!',
              child: const Icon(Icons.sms_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
