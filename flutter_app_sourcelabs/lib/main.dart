import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_indicators/progress_indicators.dart';

void main() {
  runApp(new ExampleApp());
}

class ExampleApp extends StatelessWidget {
  final List<Widget> widgets = [];
  final ListView listView = ListView();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'GROTE PLAATJES APP',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new Scaffold(
            appBar: new AppBar(title: buildTitle('DIKKE PLOATJES APP')),
            body: _getResultScaffold()));
  }

  Map<String, dynamic> _newJsonToMap(data) {
    print(data);
    Map<String, dynamic> user = jsonDecode(data);
    return user;
  }

  GridView _getResultScaffold() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 0.0, crossAxisSpacing: 0.0),
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: _getUserApi(),
          builder: (context, snapshot) {
            print(index);
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: JumpingText('FF LAAIE'));
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return InkResponse(
                    child: Image.network(_newJsonToMap(snapshot.data)['file']),
                    onTap: () {
                      Navigator.of(context).push( MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: Text('DIKKE GROTE PLAATJE'),
                            ),
                            body: Center(child: Image.network(_newJsonToMap(snapshot.data)['file'])),
                          );
                        },
                      ));
                      print(_newJsonToMap(snapshot.data)['file']);
                    },
                  );
                }
            }
            return Text('This should never happen');
          },
        );
      },
    );
  }
}

const TIMEOUT = const Duration(seconds: 5);

//getMessage() async {
//  return new Future.delayed(TIMEOUT, () => 'Welcome to your async screen');
//}

_getUserApi() async {
  var httpClient = new HttpClient();
  var uri = new Uri.https('loremflickr.com', '/json/1000/1000/opel/all');
  var request = await httpClient.getUrl(uri);
  var response = await request.close();
  var responseBody = await response.transform(Utf8Decoder()).join();
  print("Fetching HTTP resource");
  return responseBody;
}

buildTitle(String title) {
  return new Padding(
    padding: new EdgeInsets.all(10.0),
    child: new Text('DIKKE GROATE PLOATJES JO'),
  );
}
