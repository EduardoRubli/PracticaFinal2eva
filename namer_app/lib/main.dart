import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
        title: 'PROYECTO FLUTTER 2ªEVA',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 34, 172, 182)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<String> peliculas = [
    'Star Wars',
    'Pulp Fiction',
    'El Rey León',
    'The Matrix',
    'Blade Runner',
    'Titanic'
  ];
  int currentIndex = 0;
  String peli = "Star Wars";
  List<String> ultimasPelis = [];

  void getNext() {
    if (peliculas.length > 1) {
      currentIndex = (currentIndex + 1) % peliculas.length;
      peli = peliculas[currentIndex].toString();
      ultimasPelis.add(peli);
      notifyListeners();
    }
  }

  List<String> pelisFavoritas = [];

  void toggleFavorite() {
    if (pelisFavoritas.contains(peli)) {
      pelisFavoritas.remove(peli);
    } else {
      pelisFavoritas.add(peli);
    }
    notifyListeners();
  }

  void removeFavorite(String peli) {
    pelisFavoritas.remove(peli);
    notifyListeners();
  }

  void eliminarPelicula(String peli) {
    if (peliculas.length > 1) {
      peliculas.remove(peli);
      notifyListeners();
    }
  }

  void agregarPelicula(String peli) {
    peliculas.add(peli);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = FilmListPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favoritos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.list),
                    label: Text('Películas'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
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
    var peli = appState.peli;

    // Icon image.
    IconData icon;
    if (appState.pelisFavoritas.contains(peli)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 200,
            // Código del ListView principal.
            child: ListView.builder(
              shrinkWrap: true,
              reverse: true, // Los elementos se añaden de abajo a arriba.
              itemCount: context.watch<MyAppState>().ultimasPelis.length,
              itemBuilder: (context, index) {
                final peli = context.watch<MyAppState>().ultimasPelis[index];
                final isFavorite = appState.pelisFavoritas.contains(peli);
                return ListTile(
                  leading:
                      isFavorite ? Icon(Icons.favorite) : Icon(Icons.movie),
                  title: Text(peli),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          BigCard(peli: peli), // BigCard pantalla principal.
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                // Botón 'me gusta'.
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Me gusta'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                // Botón 'siguiente'.
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),
            ],
          ),
          SizedBox(height: 50),
          SizedBox(
            child: Text('Eduardo Rubli Castañeira \n PROYECTO FLUTTER 2ªEVA',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 3, 59, 82))),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.pelisFavoritas.isEmpty) {
      return Center(
        child: Text('No hay favoritos.'),
      );
    }

    return Center(
      child: Container(
        width: 300,
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Hay '
                  '${appState.pelisFavoritas.length} favoritos:'),
            ),
            for (var peli in appState.pelisFavoritas)
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text(peli),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    appState.removeFavorite(peli);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FilmListPage extends StatelessWidget {
  final TextEditingController newPeliController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Container(
        width: 300,
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Hay '
                  '${appState.peliculas.length} películas:'),
            ),
            for (var peli in appState.peliculas)
              ListTile(
                leading: Icon(Icons.movie),
                title: Text(peli),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    appState.eliminarPelicula(peli);
                  },
                ),
              ),
            TextField(
              controller: newPeliController,
              decoration: InputDecoration(hintText: 'Añadir una película...'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (newPeliController.text.isNotEmpty) {
                  appState.agregarPelicula(newPeliController.text);
                  newPeliController.clear(); // Limpiamos el text field.
                }
              },
              child: Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.peli,
  });

  final String peli;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(style: style, peli),
      ),
    );
  }
}
