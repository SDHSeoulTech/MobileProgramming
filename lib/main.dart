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
  int currentPage = 1;
  List<DrugItem> data = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = 'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList?serviceKey=QZEtVfYt%2F6%2Fb%2BR6snOu9Uer58JnlYI1i7gPkXTQYfTfqag1vgHSDTsJxWxjgnX6hTfM586vVDt3%2B600Wq94hgw%3D%3D&pageNo=$currentPage&numOfRows=5&entpName=&itemName=&itemSeq=&efcyQesitm=&useMethodQesitm=&atpnWarnQesitm=&atpnQesitm=&intrcQesitm=&seQesitm=&depositMethodQesitm=&openDe=&updateDe=&type=xml'; // API URL로 변경

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        // 'item' 엘리먼트들을 찾음
        final items = document.findAllElements('item');

        // 각 'item'에 대한 정보를 추출하여 리스트에 추가
        for (final itemElement in items) {
          final drugItem = DrugItem.fromXml(itemElement);
          data.add(drugItem);
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to load data - ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  //다음 페이지로 이동하는 함수
  void nextPage() {
    if (!isLoading) {
      currentPage++;
      data.clear();
      fetchData();
    }
  }


  // 이전 페이지로 이동하는 함수
  void previousPage() {
    if (!isLoading && currentPage > 1) {
      currentPage--;
      data.clear();
      fetchData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter XML API Example'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '약품명: ${item.itemName}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('제조사: ${item.entpName}'),
                        Text('효능: ${item.efcyQesitm}'),
                        Text('사용 방법: ${item.useMethodQesitm}'),
                  // 추가 필요한 정보들을 원하는 대로 표시
                      ],
                     ),
                    );
                  },
                ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: isLoading ? null : previousPage, // 로딩 중에는 버튼 비활성화
            tooltip: 'Previous Page',
            child: Icon(Icons.arrow_back),
            heroTag: 'previousPage',
            backgroundColor: isLoading ? Colors.grey : null,
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: isLoading ? null : nextPage,  // 로딩 중에는 버튼 비활성화
            tooltip: 'Next Page',
            child: Icon(Icons.arrow_forward),
            heroTag: 'nextPage',
            backgroundColor: isLoading ? Colors.grey : null,
          ),
        ],
      ),
    );
  }
}