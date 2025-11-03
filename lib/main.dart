import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

void main() {
  logSet();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WRSA Test',
      theme: ThemeData(
        // 이것은 애플리케이션의 테마입니다.
        //
        // 시도해보기: "flutter run"으로 애플리케이션을 실행해보세요. 애플리케이션에
        // 보라색 툴바가 있는 것을 보실 수 있습니다. 그런 다음, 앱을 종료하지 않은 상태에서
        // 아래 colorScheme의 seedColor를 Colors.green으로 변경하고
        // "핫 리로드"를 실행해보세요 (Flutter 지원 IDE에서 변경사항을 저장하거나
        // "핫 리로드" 버튼을 누르거나, 커맨드 라인으로 앱을 시작했다면 "r"을 누르세요).
        //
        // 카운터가 0으로 초기화되지 않은 것을 주목하세요; 리로드 중에도
        // 애플리케이션의 상태는 유지됩니다. 상태를 초기화하려면 핫 리스타트를 사용하세요.
        //
        // 이는 값뿐만 아니라 코드에도 적용됩니다: 대부분의 코드 변경사항은
        // 핫 리로드만으로도 테스트할 수 있습니다.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 이 위젯은 애플리케이션의 홈 페이지입니다. Stateful이기 때문에,
  // 위젯의 모습에 영향을 주는 필드를 포함하는 State 객체(아래에 정의됨)를 가집니다.

  // 이 클래스는 state에 대한 설정을 담당합니다. 부모(이 경우 App 위젯)가 제공하고
  // State의 build 메서드가 사용하는 값들(이 경우 title)을 보관합니다.
  // Widget 서브클래스의 필드들은 항상 "final"로 표시됩니다.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // setState를 호출하는 것은 Flutter 프레임워크에게 이 State에서
      // 무언가가 변경되었음을 알려주며, 이는 아래의 build 메서드를 다시 실행하게 하여
      // 화면이 업데이트된 값을 반영하도록 합니다. 만약 setState()를 호출하지 않고
      // _counter를 변경했다면, build 메서드는 다시 호출되지 않을 것이고,
      // 따라서 아무런 변화가 일어나지 않은 것처럼 보일 것입니다.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이 메서드는 setState가 호출될 때마다 다시 실행됩니다. 예를 들어
    // 위의 _incrementCounter 메서드에 의해서입니다.
    //
    // Flutter 프레임워크는 build 메서드를 다시 실행하는 것을 최적화하도록 되어 있어서,
    // 업데이트가 필요한 것만 다시 빌드할 수 있으며 위젯의 인스턴스를
    // 개별적으로 변경할 필요가 없습니다.
    // 이 메서드는 setState가 호출될 때마다 다시 실행됩니다. 예를 들어
    // 위의 _incrementCounter 메서드에 의해서입니다.
    //
    // Flutter 프레임워크는 build 메서드를 다시 실행하는 것을 최적화하도록 되어 있어서,
    // 업데이트가 필요한 것만 다시 빌드할 수 있으며 위젯의 인스턴스를
    // 개별적으로 변경할 필요가 없습니다.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: 여기에서 색상을 특정 색상으로 변경해보세요 (예를 들어
        // Colors.amber로?) 그리고 핫 리로드를 실행하여 다른 색상은 그대로 유지된 채로
        // AppBar의 색상만 변경되는 것을 확인해보세요.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 여기서는 App.build 메서드에 의해 생성된 MyHomePage 객체의 값을 가져와서
        // appbar의 제목을 설정합니다.
        title: Text(widget.title),
      ),
      body: Center(
        // Center는 레이아웃 위젯입니다. 하나의 자식을 받아서
        // 부모의 중앙에 배치합니다.
        child: Column(
          // Column도 레이아웃 위젯입니다. 자식들의 리스트를 받아서
          // 세로로 배열합니다. 기본적으로 자식들에 맞춰 가로로 크기를 조절하고,
          // 부모만큼 세로로 커지려고 합니다.
          //
          // Column은 자신의 크기와 자식들의 위치를 제어하기 위한
          // 다양한 속성을 가지고 있습니다. 여기서는 mainAxisAlignment를 사용하여
          // 자식들을 세로로 중앙에 배치합니다; Column은 세로 방향이므로
          // 주축이 세로축입니다 (교차축은 가로축이 됩니다).
          //
          // 시도해보기: "디버그 페인팅"을 실행해보세요 (IDE에서 "Toggle Debug Paint"
          // 액션을 선택하거나 콘솔에서 "p"를 누르세요), 각 위젯의
          // 와이어프레임을 볼 수 있습니다.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void logSet() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        print(record.error);
      }
      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    }
  });
}
