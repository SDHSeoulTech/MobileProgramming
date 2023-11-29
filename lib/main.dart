import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

void main() => runApp(MyApp());

class DrugItem {
  final String entpName;
  final String itemName;
  final String itemSeq;
  final String efcyQesitm;
  final String useMethodQesitm;
  final String atpnQesitm;
  final String intrcQesitm;
  final String seQesitm;
  final String depositMethodQesitm;
  final String openDe;
  final String updateDe;
  final String itemImage;
  final String bizrno;

  DrugItem({
    required this.entpName,
    required this.itemName,
    required this.itemSeq,
    required this.efcyQesitm,
    required this.useMethodQesitm,
    required this.atpnQesitm,
    required this.intrcQesitm,
    required this.seQesitm,
    required this.depositMethodQesitm,
    required this.openDe,
    required this.updateDe,
    required this.itemImage,
    required this.bizrno,
  });

  factory DrugItem.fromXml(xml.XmlElement element) {
    return DrugItem(
      entpName: utf8.decode(element.getElement('entpName')!.text.codeUnits) ?? '',
      itemName: utf8.decode(element.getElement('itemName')!.text.codeUnits) ?? '',
      itemSeq: utf8.decode(element.getElement('itemSeq')!.text.codeUnits) ?? '',
      efcyQesitm: utf8.decode(element.getElement('efcyQesitm')!.text.codeUnits) ?? '',
      useMethodQesitm: utf8.decode(element.getElement('useMethodQesitm')!.text.codeUnits) ?? '',
      atpnQesitm: utf8.decode(element.getElement('atpnQesitm')!.text.codeUnits) ?? '',
      intrcQesitm: utf8.decode(element.getElement('intrcQesitm')!.text.codeUnits) ?? '',
      seQesitm: utf8.decode(element.getElement('seQesitm')!.text.codeUnits) ?? '',
      depositMethodQesitm: utf8.decode(element.getElement('depositMethodQesitm')!.text.codeUnits) ?? '',
      openDe: utf8.decode(element.getElement('openDe')!.text.codeUnits) ?? '',
      updateDe: utf8.decode(element.getElement('updateDe')!.text.codeUnits) ?? '',
      itemImage: utf8.decode(element.getElement('itemImage')!.text.codeUnits) ?? '',
      bizrno: utf8.decode(element.getElement('bizrno')!.text.codeUnits) ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter XML API Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrugItem> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = 'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList?serviceKey=QZEtVfYt%2F6%2Fb%2BR6snOu9Uer58JnlYI1i7gPkXTQYfTfqag1vgHSDTsJxWxjgnX6hTfM586vVDt3%2B600Wq94hgw%3D%3D&pageNo=1&numOfRows=10&entpName=&itemName=&itemSeq=&efcyQesitm=&useMethodQesitm=&atpnWarnQesitm=&atpnQesitm=&intrcQesitm=&seQesitm=&depositMethodQesitm=&openDe=&updateDe=&type=xml'; // API URL로 변경

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        print(document);
        // 'item' 엘리먼트들을 찾음
        final items = document.findAllElements('item');

        // 각 'item'에 대한 정보를 추출하여 리스트에 추가
        for (final itemElement in items) {
          final drugItem = DrugItem.fromXml(itemElement);
          data.add(drugItem);
        }

        setState(() {});
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
        title: Text('Flutter XML API Example'),
      ),
      body: Center(
        child: data.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return ListTile(
              title: Text('약품명: ${item.itemName}'),
              subtitle: Text('제조사: ${item.entpName}\n효능: ${item.efcyQesitm}'),
            );
          },
        ),
      ),
    );
  }
}