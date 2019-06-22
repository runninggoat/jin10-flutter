import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() => runApp(MyApp());

var httpClient = new HttpClient();
var timeFormatter = (DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
var getColor = (int i) => i > 0 ? Colors.blue[400] : Colors.orange[800];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'jin10 news'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List news = List();

  void _getNews() async {
    var uri = new Uri.https('www.jin10.com', '/newest_1.js', {
      'rnd': Random().nextDouble().toString(),
    });
    var request = await httpClient.getUrl(uri);
    print('start requesting jin10 news... $uri');
    var response = await request.close();
    print('get response...');
    var responseBody = await response.transform(Utf8Decoder()).join();
    // print(responseBody);
    String newsLine = responseBody.toString().trim();
    int s = newsLine.indexOf('[');
    int e = newsLine.indexOf(']', s + 1);
    String newsArrStr =newsLine.substring(s, e + 1);
    print(newsArrStr);
    List newsArr = jsonDecode(newsArrStr);
    if (newsArr is List) setState(() {
      news = newsArr;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: news.length,
        itemBuilder: (BuildContext ctx, int idx) {
          String content = news[idx];
          var colorIndicator = int.parse(content.substring(2, 3));
          var time = DateTime.parse(content.substring(4, 23));
          var msg = content.substring(24, content.indexOf('#', 24));
          // print(msg);
          return Container(
            padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
            child: Container(
              width: MediaQuery.of(ctx).size.width,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF999999)))
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.message, color: getColor(colorIndicator),),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
                        child: Row(
                          children: <Widget>[
                            Text(timeFormatter(time), style: TextStyle(color: getColor(colorIndicator)),),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.only(left: 5),
                                child: Text(msg, style: TextStyle(color: getColor(colorIndicator)), overflow: TextOverflow.ellipsis, maxLines: 1,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getNews,
        tooltip: 'Get jin10 news',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
