// ✅ 화면을 그리는 데 필요한 Flutter 기본 도구들을 불러옵니다.
import 'package:flutter/material.dart';

// ✅ dart:async: 시간이 걸리는 작업(예: 타이머, 기다리기)을 다룰 때 필요해요.
// Timer 같은 기능이 여기 들어있어요!
import 'dart:async';

// ✅ 구글 광고를 앱에 넣을 수 있게 해주는 패키지입니다.
// google_mobile_ads 버전: 5.3.1
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ✅ 앱 업데이트를 자동으로 확인하고 설치할 수 있게 해주는 패키지입니다.
// in_app_update 버전: 4.2.5
import 'package:in_app_update/in_app_update.dart';

// ✅ 우리가 만든 메인 화면(MainScreen)을 가져옵니다.
// 스플래시 화면이 끝나면 이 화면으로 이동해요.
import 'main.dart';

import 'package:flutter/foundation.dart';

// ✅ SplashScreen: 앱을 켰을 때 가장 먼저 보이는 "로딩 화면"입니다.
// 앱이 준비되는 동안 광고 로딩과 업데이트 확인을 진행해요.
// StatefulWidget = 화면 상태가 바뀔 수 있는 위젯 (광고가 로드되면 상태가 바뀌니까요)
class SplashScreen extends StatefulWidget {
  // super.key: Flutter가 위젯을 구별하기 위한 번호표입니다.
  // ✅ 최신 방식: const 생성자 + super.key 사용 (Flutter 3.x 권장)
  const SplashScreen({super.key});

  // createState: 이 위젯의 상태 관리자(_SplashScreenState)를 만듭니다.
  // ✅ 최신 방식: State<SplashScreen>으로 타입을 명확히 써줍니다.
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// ✅ SplashScreen의 실제 동작을 담당하는 클래스입니다.
// 언더바(_)로 시작 = 이 파일 안에서만 사용 가능한 비공개 클래스
class _SplashScreenState extends State<SplashScreen> {
  // 전면 광고(화면 전체를 덮는 광고)를 저장하는 변수입니다.
  // ?가 붙으면 "없을 수도 있다"는 뜻이에요 (광고 로딩 전에는 null)
  InterstitialAd? _interstitialAd;

  // ✅ initState: 이 화면이 처음 만들어질 때 단 한 번 실행되는 함수입니다.
  // 마치 앱이 처음 켜질 때 준비 작업을 하는 것처럼요!
  @override
  void initState() {
    super.initState(); // 부모 클래스의 initState도 반드시 먼저 호출해야 합니다.
    _checkForUpdate(); // 앱 업데이트가 있는지 확인 시작!
  }

  // ✅ 구글 플레이 스토어에 새 버전 업데이트가 있는지 확인하는 함수입니다.
  // async = 시간이 걸리는 작업을 "기다리면서" 처리하겠다는 뜻이에요.
  // Future<void> = 결과값 없이 비동기로 실행되는 함수라는 뜻입니다.
  Future<void> _checkForUpdate() async {
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _goToHomePage();
        }
      });
      return;
    }
    try {
      // await: 업데이트 정보가 올 때까지 여기서 잠깐 기다립니다.
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      // 업데이트가 있는 경우: 즉시 업데이트 화면을 띄웁니다.
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate(); // 강제 업데이트 실행
      } else {
        // 업데이트가 없는 경우: 광고 로딩 → 홈 화면으로 이동
        _loadInterstitialAd();
        _navigateToHome();
      }
    } catch (e) {
      // ⚠️ 업데이트 확인 중 오류가 생겼을 때 (인터넷 없음 등)
      // ✅ 최신 방식: print() 대신 debugPrint()를 사용합니다.
      // debugPrint는 개발할 때만 로그가 출력되어 배포 앱에서 더 안전해요!
      debugPrint('Failed to check for update: $e');
      _loadInterstitialAd(); // 오류가 나도 광고는 로드 시도
      _navigateToHome(); // 오류가 나도 홈 화면으로 이동
    }
  }

  // ✅ 전면 광고(화면 전체를 가리는 광고)를 미리 불러오는 함수입니다.
  // 광고는 로딩 시간이 필요하기 때문에 미리 준비해둬요!
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/1033173712', // 테스트용 광고 ID (배포 시 실제 ID로 변경!)
      request: const AdRequest(), // ✅ const: 변하지 않는 값이므로 const 사용 (메모리 절약)
      adLoadCallback: InterstitialAdLoadCallback(
        // 광고 로딩이 성공했을 때 실행됩니다.
        onAdLoaded: (ad) {
          _interstitialAd = ad; // 로딩된 광고를 변수에 저장
        },
        // 광고 로딩이 실패했을 때 실행됩니다.
        onAdFailedToLoad: (LoadAdError error) {
          // ✅ 최신 방식: print() 대신 debugPrint() 사용
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  // ✅ 3초 후에 홈 화면으로 이동하는 함수입니다.
  // 광고가 준비됐으면 광고를 먼저 보여주고 이동해요!
  void _navigateToHome() {
    // Timer: 일정 시간 후에 코드를 실행하는 타이머입니다.
    // ✅ const Duration: 변하지 않는 시간 값이므로 const 사용
    Timer(const Duration(seconds: 3), () {
      if (_interstitialAd != null) {
        // 전면 광고가 준비됐을 때: 광고의 전체 화면 이벤트를 등록합니다.
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          // 광고를 닫았을 때 → 홈 화면으로 이동
          onAdDismissedFullScreenContent: (ad) {
            _goToHomePage();
          },
          // 광고 보여주기에 실패했을 때도 → 홈 화면으로 이동
          onAdFailedToShowFullScreenContent: (ad, error) {
            _goToHomePage();
          },
        );
        _interstitialAd!.show(); // 전면 광고를 화면에 보여줍니다!
      } else {
        // 광고가 아직 준비 안 됐을 때: 바로 홈 화면으로 이동
        _goToHomePage();
      }
    });
  }

  // ✅ 실제로 홈 화면(MainScreen)으로 화면을 교체하는 함수입니다.
  void _goToHomePage() {
    // ✅ mounted: 이 위젯이 아직 화면에 살아있는지 확인합니다.
    // mounted가 false면 위젯이 이미 사라진 것이라 이동하면 오류 나요!
    if (!mounted) return;

    // pushReplacement: 현재 화면을 새 화면으로 "교체"합니다.
    // push와 다른 점: 뒤로가기 버튼을 눌러도 스플래시 화면으로 돌아오지 않아요!
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // ✅ const: MainScreen은 변하지 않으므로 const로 성능 최적화
        builder: (context) => const MainScreen(),
      ),
    );
  }

  // ✅ 화면에 실제로 보여줄 UI를 만드는 함수입니다.
  @override
  Widget build(BuildContext context) {
    // ✅ const Scaffold: 내용이 고정되어 바뀌지 않으므로 const 사용 (성능 최적화)
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'), // 로딩 중에 보여줄 텍스트 (실제 앱에선 로고 이미지로 바꾸세요!)
      ),
    );
  }
}
