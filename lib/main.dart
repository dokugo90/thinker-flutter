import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyData {
  final String ?name;
  MyData({this.name});

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      name: json['name'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Thinker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse("ws://localhost:5000"));
  List data = <dynamic>[];
  String message = "Empty Message";
  Timer ?_timer;

  void sendMessage() async {
    setState(() {
      getMessages();
    });
    try {
      Uri dbUri = Uri.parse("http://192.168.88.16:5000/send");
    var req = await http.post(dbUri, body: {"message": message});
    print("sent Data");
    } catch(err) {
      print("Error $err");
    }
  }

  void getMessages() async {
    try {
      Uri dbUri = Uri.parse("http://192.168.88.16:5000/messages");
    var req = await http.get(dbUri);
    var res = jsonDecode(req.body);
    print("Requested Data");
    setState(() {
      data = res;
    });
    } catch(err) {
      print("Error yuhh $err");
    }
  }


  void myPrinter() {
    print("It works");
  }

  @override
  void initState() {
    super.initState();

   /*_timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        getMessages();
      });
    });*/
    _channel.stream.listen((newData) {
      setState(() {
        data = newData;
      });
    });
    getMessages();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: null,
          icon: Icon(Icons.whatsapp),
          tooltip: "Chat App",
        ),
        title: Text("Thinker"),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.purple,
                 Colors.lightBlue
              ]
            )
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 120,
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        onTap: null,
                          title: Text(data[index]["text_message"].toString()),
                          subtitle: Text(data[index]["name"].toString()),
                          trailing: Text(data[index]["date"].toString()),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(data[index]["image"].toString() ?? "https://media.istockphoto.com/id/1223671392/fr/vectoriel/photo-de-profil-par-d%C3%A9faut-avatar-photo-placeholder-illustration-de-vecteur.jpg?s=170667a&w=0&k=20&c=EqD6q8IUqwN_bgGec0UBhh3tk2Zuur5lezDDlQsGdPY=", ),
                          ),
                      );
                    })
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Expanded(
                      child: SizedBox(
                        child: TextField(
                          onChanged: (String value) {
                            setState(() {
                              message = value;
                            });
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Message",
                            hintText: "Enter Message",
                            prefixIcon: Icon(Icons.message)
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    FloatingActionButton(
                      onPressed: sendMessage,
                      tooltip: "Send Message",
                      child: Icon(Icons.send),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );

  }
}
