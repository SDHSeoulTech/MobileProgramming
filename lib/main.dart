import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter REST API Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final encodeKey = 'QZEtVfYt%2F6%2Fb%2BR6snOu9Uer58JnlYI1i7gPkXTQYfTfqag1vgHSDTsJxWxjgnX6hTfM586vVDt3%2B600Wq94hgw%3D%3D';
      final decodeKey = 'QZEtVfYt/6/b+R6snOu9Uer58JnlYI1i7gPkXTQYfTfqag1vgHSDTsJxWxjgnX6hTfM586vVDt3+600Wq94hgw==';

      final response = await http.get(
        Uri.parse('	http://apis.data.go.kr/B551182/msupCmpnMeftInfoService'),
        headers: {'Authorization': 'EncodeKey $encodeKey, DecodeKey $decodeKey'},
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
        });
      } else {
        print('Failed to load data - ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter REST API Example'),
      ),
      body: Center(
        child: data.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data[index]['title']),
              subtitle: Text(data[index]['body']),
            );
          },
        ),
      ),
    );
  }
}
