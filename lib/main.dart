// ✅ Flutter에서 화면을 그리는 데 필요한 기본 도구들을 불러옵니다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:basic/splash_screen.dart';
import 'package:basic/home_screen.dart';
import 'package:basic/relationship_screen.dart';
import 'package:basic/settings_screen.dart';
import 'package:basic/statistics_screen.dart';
import 'package:basic/database_service.dart';
import 'package:basic/astrology_service.dart';
import 'package:basic/google_sheets_service.dart';
import 'package:basic/themes.dart';
import 'package:timezone/data/latest.dart' as tz;

// ✅ 앱이 시작될 때 제일 먼저 실행되는 함수입니다.
// 마치 컴퓨터를 켜면 바탕화면이 뜨는 것처럼, 앱이 켜지면 이 함수가 먼저 달립니다!
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  // 📦 로컬 DB 및 천문 계산 엔진, 시간대 초기화
  try {
    tz.initializeTimeZones();
    await DatabaseService.init();
    await AstrologyService.init();
  } catch (e) {
    // DB 초기화 실패 시 에러 화면 노출
    print('Initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '앱 초기화 중 오류가 발생했습니다.\n앱을 완전히 종료 후 다시 실행해 주세요.\n\n오류: $e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // ☁️ Google Sheets 초기화 및 클라우드 동기화 (앱 진입 속도 향상을 위해 백그라운드 비동기 실행)
  // silent: true로 호출하여 이미 로그인된 경우에만 자동으로 동기화 작업을 수행하고,
  // 로그인되지 않은 상태라면 로그인 UI 팝업을 강제로 띄우지 않습니다.
  GoogleSheetsService.signIn(silent: true)
      .then((success) {
        if (success) {
          GoogleSheetsService.pullAll(); // 클라우드 → 로컬 병합
        }
      })
      .catchError((e) {
        debugPrint('Google Sheets background init error: $e'); // 오프라인이면 로컬로만 동작
      });

  MobileAds.instance.initialize();
  runApp(const MyApp());
}

// ✅ 앱 전체를 감싸는 최상위 위젯입니다.
// StatelessWidget = 한번 그리면 바뀌지 않는 위젯이에요.
// (앱의 테마·제목 같은 기본 설정은 바뀌지 않으니까요)
class MyApp extends StatelessWidget {
  // super.key: 위젯을 구별하기 위한 고유 번호표입니다. Flutter가 요구해요.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: 구글 Material Design 스타일의 앱을 만드는 틀입니다.
    return MaterialApp(
      title: 'Healer project', // 앱의 제목
      // 🎨 앱 전체의 색상 테마를 설정합니다.
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: ThemeMode.light, // 밝은 낮 테마를 기본으로 사용합니다.
      // 🏠 앱을 켰을 때 가장 먼저 보여줄 화면 = 스플래시 화면(로딩 화면)
      // SplashScreen이 끝나면 알아서 MainScreen으로 이동합니다.
      home: SplashScreen(),
    );
  }
}

// ✅ 하단 탭바(홈·관계·통계·설정)를 포함하는 메인 화면입니다.
// StatefulWidget = 상태(현재 선택된 탭)가 바뀔 수 있는 위젯이에요.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // createState: 이 위젯의 "상태 관리자"를 만듭니다.
  @override
  State<MainScreen> createState() => _MainScreenState();
}

// ✅ MainScreen의 실제 동작(로직)을 담당하는 상태 클래스입니다.
// 언더바(_)로 시작하면 이 파일 안에서만 쓸 수 있다는 뜻이에요. (비공개)
class _MainScreenState extends State<MainScreen> {
  // 현재 몇 번째 탭이 선택되었는지 저장하는 변수입니다.
  // 0 = 홈, 1 = 관계/궁합, 2 = 통계, 3 = 설정
  int _selectedIndex = 0;

  // 탭마다 보여줄 화면 목록입니다.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(title: '내담자 임상 기록'), // 0번: 홈 화면 (내담자 목록)
    RelationshipScreen(), // 1번: 관계 & 궁합 (시나스트리/컴포짓)
    StatisticsScreen(), // 2번: 임상 통계 분석 화면
    SettingsScreen(), // 3번: 설정 화면
  ];

  // 탭을 눌렀을 때 호출되는 함수입니다.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 탭 번호를 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📄 현재 선택된 탭에 맞는 화면을 중앙에 보여줍니다.
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      // 📍 화면 아래쪽에 탭 버튼들을 보여줍니다.
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: '내담자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: '관계 & 궁합',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: '임상 통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭을 강조 표시
        onTap: _onItemTapped, // 탭을 누르면 _onItemTapped 함수 호출
      ),
    );
  }
}
