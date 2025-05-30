import "package:app2/main.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class CarruselfocusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          // Ponemos la imagen de fondo aquí
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
              opacity: 0.9, // Ajusta la opacidad según sea necesario
            ),
          ),
          child: AppBar(
            title: Text("Focus Recommendations"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: favorites.isEmpty
            ? Center(
                child: Text(
                  'No recommendations yet.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text('You have '
                        '${appState.favorites.length} users:'),
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
              ),
      ),
    );
  }
}
