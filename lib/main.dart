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
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 26, 255, 0)),
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

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    print(favorites);
    notifyListeners();
  }

  void toggerUnLike(pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  var navExtendStatus = false;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoriteListPage();
        break;
      case 2:
        page = MessageListWidget();
        break;
      default:
        page = Placeholder();
        break;
    }

    return LayoutBuilder(
      builder: (context, constrains) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(child: NavigationRail(
                extended: constrains.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text("Home")
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text("Favorite")
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.message),
                    label: Text("Message")
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.device_unknown),
                    label: Text("Favorite")
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                }
              )),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      ElevatedButton.icon(onPressed: () {
                        setState(() {
                          navExtendStatus = !navExtendStatus;
                        });
                      }, icon: Icon(navExtendStatus ? Icons.expand_more : Icons.expand_less), label: Text('')),
                      page
                    ],
                  ),
                )
              )
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeButtonWidget(icon: icon, appState: appState),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Next"),
              ),
            ]
          )
        ]
      ),
    );
  }
}

class Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Placeholder"));
  }
}

class FavoriteListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("You have ${appState.favorites.length} favorites"),
        SizedBox(height: 10),
        if (appState.favorites.isNotEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Favorites:"),
              SizedBox(width: 10),
              for (var pair in appState.favorites)
                FavoritesItem(appState: appState, pair: pair)
            ]
          )
        else 
          Text("No favorites yet."),
      ]
    ));
  }
}

class FavoritesItem extends StatelessWidget {
  const FavoritesItem({
    super.key,
    required this.appState,
    required this.pair,
  });

  final MyAppState appState;
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            appState.toggerUnLike(pair);
          },
          key: ValueKey(pair),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 12),
              SizedBox(width: 8),
              Text('${pair.first} ${pair.second}'),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class LikeButtonWidget extends StatelessWidget {
  const LikeButtonWidget({
    super.key,
    required this.icon,
    required this.appState,
  });

  final IconData icon;
  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text("Like"),
      onPressed: () {
        appState.toggleFavorite();
      },
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
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class MessageListWidget extends StatelessWidget {
  var messages = ["This is First Message", 'This is Second Message', "This is Third Message"];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("MessageList:"),
        for(var message in messages)
          ListTitle(title: message)
      ],
    );
  }
}

class ListTitle  extends StatelessWidget {
  const ListTitle({
    super.key, 
    required this.title
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(title))),
        SizedBox(height:10),
      ]
    );
  }
}