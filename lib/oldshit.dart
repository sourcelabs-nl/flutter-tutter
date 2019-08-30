import 'dart:convert';

import 'package:async_loader/async_loader.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() => runApp(MyApp());

_getUserApi() async {
  var httpClient = new HttpClient();
  var uri = new Uri.https('api.github.com', '/users/1');
  var request = await httpClient.getUrl(uri);
  var response = await request.close();
  var responseBody = await response.transform(Utf8Decoder()).join();
  return responseBody;
}

final GlobalKey<AsyncLoaderState> _asyncLoaderState =
new GlobalKey<AsyncLoaderState>();

var _asyncLoader = new AsyncLoader(
  key: _asyncLoaderState,
  initState: () async => await _getUserApi(),
  renderLoad: () => new CircularProgressIndicator(),
  renderError: ([error]) => new Text('Error loading, soz'),
  renderSuccess: ({data}) => null
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Startup name generator',
        theme: ThemeData(          // Add the 3 lines from here...
          primaryColor: Colors.indigo,
        ),
        home: RandomWords());
  }
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _likes = Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }

          final int index = i ~/ 2;

          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadyLiked = _likes.contains(pair);
    return ListTile(
      title: Text(pair.asPascalCase, style: _biggerFont),
      trailing: Icon(
        alreadyLiked ? Icons.check : Icons.check_box_outline_blank,
        color: alreadyLiked ? Colors.lightBlue : null,
      ),
      onTap: () {
        setState(() {
          if (alreadyLiked) {
            _likes.remove(pair);
          } else {
            _likes.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _likes.map(
                  (WordPair pair) {
                    return ListTile(
                      title: Text(
                        pair.asPascalCase,
                        style: _biggerFont,
                      ),
                    );
              });
          final List<Widget> divided = ListTile
          .divideTiles(context: context, tiles: tiles)
          .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
              body: ListView(children: divided),
          );
        },
      )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup name generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.airline_seat_flat_angled), onPressed: _pushSaved)
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}
