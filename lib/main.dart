import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String? key = dotenv.env['KEY'];



void main() async {
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(MyApp());
}

class SelectedDrugsModel extends ChangeNotifier {
  List<DrugItem> selectedDrugs = [];

  SelectedDrugsModel() {
    _loadSelectedDrugs();
  }


  void _saveSelectedDrugs() async {
    final file = await _getLocalFile();
    final jsonData = selectedDrugs.map((drug) => drug.toJson()).toList();
    final jsonString = json.encode(jsonData);
    await file.writeAsString(jsonString);
    //print(jsonString);
    //debugPrint('저장완로');
  }

  void _loadSelectedDrugs() async {
    try {
      final file = await _getLocalFile();
      if (!file.existsSync()) {
        await file.create();
        return;
      }
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      //debugPrint('확인용 $jsonString');
      final loadedDrugs = (jsonData.toList() as List<dynamic>).map((data) => DrugItem.fromJson(data));
      selectedDrugs.addAll(loadedDrugs);

      notifyListeners();
    } catch (e) {
      print('Error loading selected drugs: $e');
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    debugPrint('${directory.path}');
    return File('${directory.path}/selectedDrugs.json');
  }

  void toggleSelection(DrugItem item) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index == -1) {
      selectedDrugs.add(item);
    } else {
      selectedDrugs.removeAt(index);
    }
    _saveSelectedDrugs();
    notifyListeners(); // 변경 사항을 구독자에게 알림
  }

  void unselectDrug(DrugItem item) {
    selectedDrugs.removeWhere((element) => element.itemSeq == item.itemSeq);
    _saveSelectedDrugs();
    notifyListeners();
  }

  void toggleAlarm(DrugItem item) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      selectedDrugs[index].isAlarmSet = !selectedDrugs[index].isAlarmSet;
      notifyListeners();
    }
  }

  void setAlarmTime(DrugItem item, TimeOfDay time) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      selectedDrugs[index].alarmTime = time;
      notifyListeners();
    }
  }

}

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
  bool isSelected = false;
  bool isAlarmSet = false;
  TimeOfDay? alarmTime;

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
    required this.isSelected,
    required isAlarmSet,
    TimeOfDay? alarmTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'entpName': entpName,
      'itemName': itemName,
      'itemSeq': itemSeq,
      'efcyQesitm': efcyQesitm,
      'useMethodQesitm': useMethodQesitm,
      'atpnQesitm': atpnQesitm,
      'intrcQesitm': intrcQesitm,
      'seQesitm': seQesitm,
      'depositMethodQesitm': depositMethodQesitm,
      'openDe': openDe,
      'updateDe': updateDe,
      'itemImage': itemImage,
      'bizrno': bizrno,
      'isSelected': isSelected,
      'isAlarmSet': isAlarmSet,
      'alarmTime': alarmTime != null ? {'hour': alarmTime!.hour, 'minute': alarmTime!.minute} : null,
    };
  }

  factory DrugItem.fromJson(Map<String, dynamic> json) {
    return DrugItem(
      entpName: json['entpName'],
      itemName: json['itemName'],
      itemSeq: json['itemSeq'],
      efcyQesitm: json['efcyQesitm'],
      useMethodQesitm: json['useMethodQesitm'],
      atpnQesitm: json['atpnQesitm'],
      intrcQesitm: json['intrcQesitm'],
      seQesitm: json['seQesitm'],
      depositMethodQesitm: json['depositMethodQesitm'],
      openDe: json['openDe'],
      updateDe: json['updateDe'],
      itemImage: json['itemImage'],
      bizrno: json['bizrno'],
      isSelected : true,
      isAlarmSet: json['isAlarmSet'] ?? false,
      alarmTime: json['alarmTime'] != null
        ? TimeOfDay(hour: json['alarmTime']['hour'], minute: json['alarmTime']['minute'])
          : null,
    );
  }

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
      isSelected: false,
      isAlarmSet: false,
      alarmTime: null,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedDrugsModel(), // SelectedDrugsModel을 프로바이더로 등록
      child: MaterialApp(
        title: 'Flutter XML API Example',
        home: MyHomePage(),
      ),
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
  TextEditingController searchController = TextEditingController();
  String searchText = "";

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
      final url = 'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList?serviceKey=$key&pageNo=$currentPage&numOfRows=5&entpName=&itemName=$searchText&itemSeq=&efcyQesitm=&useMethodQesitm=&atpnWarnQesitm=&atpnQesitm=&intrcQesitm=&seQesitm=&depositMethodQesitm=&openDe=&updateDe=&type=xml'; // API URL로 변경

      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);

        final items = document.findAllElements('item');

        for (final itemElement in items) {
          final drugItem = DrugItem.fromXml(itemElement);
          data.add(drugItem);
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to load data - ${response.statusCode}');
        // Connection timed out이면 재시도
        if (response.statusCode == 504 || response.statusCode == 503) {
          print('Retrying after a delay...');
          await Future.delayed(Duration(seconds: 5));
          await fetchData();
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error, stackTrace) {
      print('Error fetching data: $error');
      print('StackTrace: $stackTrace');
      // 에러가 발생했을 때도 재시도
      print('Retrying after a delay...');
      await Future.delayed(Duration(seconds: 5));
      await fetchData();
    }
  }

  void nextPage() {
    if (!isLoading) {
      currentPage++;
      data.clear();
      fetchData();
    }
  }

  void previousPage() {
    if (!isLoading && currentPage > 1) {
      currentPage--;
      data.clear();
      fetchData();
    }
  }


  @override
  Widget build(BuildContext context) {
    final selectedDrugsModel = context.watch<SelectedDrugsModel>(); // 모델 읽어오기
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '약품명으로 검색',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      searchText = "";
                      data.clear();
                      currentPage = 1;
                      fetchData();
                    });
                  },
                  icon: Icon(Icons.clear),
                )
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searchText = searchController.text;
                data.clear();
                currentPage = 1;
                fetchData();
              });
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlarmSettingsScreen()),
              );
            },
            icon: Icon(Icons.notifications), // 알람 설정 아이콘 또는 다른 아이콘으로 변경 가능
          ),
        ],
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
                      color: selectedDrugsModel.selectedDrugs.any((selectedItem) => selectedItem.itemSeq == item.itemSeq)
                          ? Colors.blue // 선택된 경우 배경색을 파란색으로 변경
                          : Colors.white, // 선택되지 않은 경우 배경색을 흰색으로 유지
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
                        //선택된 약품 여부에 따라 UI 업데이트
                        //Text('선택 여부: ${selectedDrugsModel.selectedDrugs.any((selectedItem) => selectedItem.itemSeq == item.itemSeq)}'),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedDrugsModel.selectedDrugs.any((selectedItem) => selectedItem.itemSeq == item.itemSeq)) {
                              // 이미 선택된 경우
                              selectedDrugsModel.unselectDrug(item);
                            } else {
                              // 선택되지 않은 경우
                              selectedDrugsModel.toggleSelection(item);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedDrugsModel.selectedDrugs.any((selectedItem) => selectedItem.itemSeq == item.itemSeq)
                                ? Colors.red // 선택된 경우 버튼 색을 빨간색으로 변경
                                : null, // 선택되지 않은 경우 기본 버튼 색 사용
                          ),
                          child: Text(selectedDrugsModel.selectedDrugs.any((selectedItem) => selectedItem.itemSeq == item.itemSeq)
                              ? '약품 해제' // 선택된 경우 버튼 텍스트를 '약품 해제'로 변경
                              : '약품 선택'), // 선택되지 않은 경우 기본 버튼 텍스트 사용
                        ),

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

class AlarmSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedDrugsModel = context.watch<SelectedDrugsModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('알람 설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '선택한 약 목록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedDrugsModel.selectedDrugs.length,
                itemBuilder: (context, index) {
                  final drugItem = selectedDrugsModel.selectedDrugs[index];
                  return ListTile(
                    title: Text(drugItem.itemName),
                    subtitle: Text(drugItem.entpName),
                    trailing: Checkbox(
                      value: drugItem.isAlarmSet,
                      onChanged: (value) {
                        selectedDrugsModel.toggleAlarm(drugItem);
                        if (value!) {
                          // 알람을 설정하려는 경우 알람 시간 선택 다이얼로그 표시
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          ).then((time) {
                            if (time != null) {
                              selectedDrugsModel.setAlarmTime(drugItem, time);
                            } else {
                              // 사용자가 시간 선택을 취소한 경우 알람 해제
                              selectedDrugsModel.toggleAlarm(drugItem);
                            }
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}