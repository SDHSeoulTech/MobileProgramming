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

  void toggleTaken(DrugItem item) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      selectedDrugs[index].toggleTaken();
      notifyListeners();
    }
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

  void toggleMorningAlarm(DrugItem item) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      selectedDrugs[index].isMorningAlarmSet = !selectedDrugs[index].isMorningAlarmSet;
      notifyListeners();
    }
  }

  void toggleLunchAlarm(DrugItem item) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      selectedDrugs[index].isLunchAlarmSet = !selectedDrugs[index].isLunchAlarmSet;
      notifyListeners();
    }
  }

  void toggleDinnerAlarm(DrugItem item) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      selectedDrugs[index].isDinnerAlarmSet = !selectedDrugs[index].isDinnerAlarmSet;
      notifyListeners();
    }
  }

  void setAlarmTime(DrugItem item, String mealType, TimeOfDay time) {
    final index = selectedDrugs.indexWhere((element) => element.itemSeq == item.itemSeq);
    if (index != -1) {
      switch (mealType) {
        case '아침':
          selectedDrugs[index].morningAlarmTime = time;
          selectedDrugs[index].isMorningAlarmSet = true;
          break;
        case '점심':
          selectedDrugs[index].lunchAlarmTime = time;
          selectedDrugs[index].isLunchAlarmSet = true;
          break;
        case '저녁':
          selectedDrugs[index].dinnerAlarmTime = time;
          selectedDrugs[index].isDinnerAlarmSet = true;
          break;
        default:
          break;
      }
      _saveSelectedDrugs();
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
  bool isMorningAlarmSet = false;
  bool isLunchAlarmSet = false;
  bool isDinnerAlarmSet = false;
  TimeOfDay? morningAlarmTime; // 아침 알람 시간
  TimeOfDay? lunchAlarmTime;   // 점심 알람 시간
  TimeOfDay? dinnerAlarmTime;  // 저녁 알람 시간
  bool isTaken;

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
    required this.isMorningAlarmSet,
    required this.isLunchAlarmSet,
    required this.isDinnerAlarmSet,
    required this.morningAlarmTime,
    required this.lunchAlarmTime,
    required this.dinnerAlarmTime,
    required this.isTaken,
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
      'isMorningAlarmSet': isMorningAlarmSet,
      'isLunchAlarmSet': isLunchAlarmSet,
      'isDinnerAlarmSet': isDinnerAlarmSet,
      'morningAlarmTime': morningAlarmTime != null
          ? {'hour': morningAlarmTime!.hour, 'minute': morningAlarmTime!.minute}
          : null,
      'lunchAlarmTime': lunchAlarmTime != null
          ? {'hour': lunchAlarmTime!.hour, 'minute': lunchAlarmTime!.minute}
          : null,
      'dinnerAlarmTime': dinnerAlarmTime != null
          ? {'hour': dinnerAlarmTime!.hour, 'minute': dinnerAlarmTime!.minute}
          : null,
      'isTaken': isTaken,
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
      isMorningAlarmSet: json['isMorningAlarmSet'] ?? false,
      isLunchAlarmSet: json['isLunchAlarmSet'] ?? false,
      isDinnerAlarmSet: json['isDinnerAlarmSet'] ?? false,
      morningAlarmTime: json['morningAlarmTime'] != null
          ? TimeOfDay(hour: json['morningAlarmTime']['hour'], minute: json['morningAlarmTime']['minute'])
          : null,
      lunchAlarmTime: json['lunchAlarmTime'] != null
          ? TimeOfDay(hour: json['lunchAlarmTime']['hour'], minute: json['lunchAlarmTime']['minute'])
          : null,
      dinnerAlarmTime: json['dinnerAlarmTime'] != null
          ? TimeOfDay(hour: json['dinnerAlarmTime']['hour'], minute: json['dinnerAlarmTime']['minute'])
          : null,
      isTaken: json['isTaken'] ?? false,
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
      isMorningAlarmSet: false,
      isLunchAlarmSet: false,
      isDinnerAlarmSet: false,
      morningAlarmTime: null,
      lunchAlarmTime: null,
      dinnerAlarmTime: null,
      isTaken: false
    );
  }

  void toggleTaken() {
    isTaken = !isTaken;
  }

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedDrugsModel(), // SelectedDrugsModel을 프로바이더로 등록
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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

class AlarmSettingsScreen extends StatefulWidget {
  @override
  _AlarmSettingsScreenState createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  static const TimeOfDay unsetTime = TimeOfDay(hour: -1, minute: -1);

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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showTimePickerDialog(
                                context, selectedDrugsModel, drugItem);
                          },
                          child: Text('알람 설정'),
                        ),
                      ],
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

  Future<void> _showTimePickerDialog(BuildContext context,
      SelectedDrugsModel selectedDrugsModel, DrugItem drugItem) async {
    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('알람 설정 - ${drugItem.itemName}'),
            content: Column(
              children: [
                _buildTimePicker(
                    context, drugItem, '아침', selectedDrugsModel, drugItem.morningAlarmTime),
                _buildTimePicker(
                    context, drugItem, '점심', selectedDrugsModel, drugItem.lunchAlarmTime),
                _buildTimePicker(
                    context, drugItem, '저녁', selectedDrugsModel, drugItem.dinnerAlarmTime),
              ],
            ),
          ),
    );
  }

  Widget _buildTimePicker(BuildContext context, DrugItem drugItem,
      String mealType, SelectedDrugsModel selectedDrugsModel,
      TimeOfDay? initialTime) {
    bool isAlarmSet;
    switch (mealType) {
      case '아침':
        isAlarmSet = drugItem.isMorningAlarmSet;
        break;
      case '점심':
        isAlarmSet = drugItem.isLunchAlarmSet;
        break;
      case '저녁':
        isAlarmSet = drugItem.isDinnerAlarmSet;
        break;
      default:
        isAlarmSet = false;
        break;
    }

    return Wrap(
      children: [
        Checkbox(
          value: isAlarmSet && initialTime != null && initialTime != unsetTime,
          onChanged: (value) {
            if (value!) {
              _showTimePicker(
                  context, drugItem, mealType, selectedDrugsModel, initialTime);
            } else {
              _removeAlarm(context, drugItem, mealType, selectedDrugsModel);
            }
          },
        ),
        Text('$mealType 알람 설정'),
      ],
    );
  }

  void _removeAlarm(BuildContext context, DrugItem drugItem, String mealType,
      SelectedDrugsModel selectedDrugsModel) {
    switch (mealType) {
      case '아침':
        selectedDrugsModel.setAlarmTime(drugItem, mealType, unsetTime);
        break;
      case '점심':
        selectedDrugsModel.setAlarmTime(drugItem, mealType, unsetTime);
        break;
      case '저녁':
        selectedDrugsModel.setAlarmTime(drugItem, mealType, unsetTime);
        break;
      default:
        break;
    }
    Navigator.pop(context); // 다이얼로그를 닫습니다.
    _showTimePickerDialog(
    context, selectedDrugsModel, drugItem,
    );
  }

  Future<void> _showTimePicker(BuildContext context, DrugItem drugItem,
      String mealType, SelectedDrugsModel selectedDrugsModel,
      TimeOfDay? initialTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final updatedTime = TimeOfDay(
          hour: pickedTime.hour, minute: pickedTime.minute);

      switch (mealType) {
        case '아침':
          selectedDrugsModel.setAlarmTime(drugItem, mealType, updatedTime);
          break;
        case '점심':
          selectedDrugsModel.setAlarmTime(drugItem, mealType, updatedTime);
          break;
        case '저녁':
          selectedDrugsModel.setAlarmTime(drugItem, mealType, updatedTime);
          break;
        default:
          break;
      }

      // 변경 사항이 저장되도록 알람 창 다시 표시
      Navigator.of(context).pop();
      await _showTimePickerDialog(
        context, selectedDrugsModel, drugItem,
      );
    }
  }

}

