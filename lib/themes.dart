import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎨 Themes: 앱의 예쁜 옷(테마)들이 가득 들어있는 옷장이에요!
/// 밝은 낮 테마(Light Theme)와 어두운 밤 테마(Dark Theme) 두 가지 옷이 준비되어 있어요.
class Themes {
  // ☀️ 낮 모드(밝은 모드) 옷에 쓸 색상 물감들이에요.
  static const Color _lightBackground = Color(
    0xFFF8F6F0,
  ); // 🍦 따뜻하고 부드러운 아이보리색 (바탕색)
  static const Color _lightSurface = Color(
    0xFFFFFDF8,
  ); // 🥛 부드러운 크림색 (메뉴나 상자 겉면)
  static const Color _lightCard = Color(0xFFFFFFFF); // ✉️ 순백색 (글이나 카드를 담는 상자)
  static const Color _lightPrimary = Color(
    0xFF2C3E50,
  ); // 🌌 깊고 어두운 밤하늘색 (가장 중요한 글자나 아이콘)
  static const Color _lightSecondary = Color(
    0xFFD4AF37,
  ); // 👑 반짝이는 황금색 (두 번째로 중요한 포인트 색상)
  static const Color _lightText = Color(0xFF1A1A2E); // ✒️ 아주 깊은 남색 (일반 글자색)
  static const Color _lightTextSecondary = Color(
    0xFF3A3A4A,
  ); // ✏️ 부드러운 회색 (덜 중요한 작은 글자색)

  // 🌙 밤 모드(어두운 모드) 옷에 쓸 색상 물감들이에요.
  static const Color _darkBackground = Color(0xFF0E0E12); // 🌌 깊고 어두운 블랙 (바탕색)
  static const Color _darkSurface = Color(
    0xFF14141A,
  ); // 🌌 어두운 차콜 그레이 (메뉴나 상자 겉면)
  static const Color _darkCard = Color(0xFF1A1A24); // 💎 차분한 다크 그레이 (카드를 담는 상자)
  static const Color _darkPrimary = Color(
    0xFFE8D5B7,
  ); // 🌙 은은한 달빛 크림색 (가장 중요한 글자나 아이콘)
  static const Color _darkSecondary = Color(
    0xFFD4AF37,
  ); // 👑 반짝이는 황금색 (여기서도 황금색은 포인트로 써요!)
  static const Color _darkText = Color(0xFFF0EDE5); // ⭐️ 반짝이는 별빛 화이트 (일반 글자색)
  static const Color _darkTextSecondary = Color(
    0xFFB8B5AD,
  ); // 🌫️ 부드러운 은빛 회색 (덜 중요한 작은 글자색)

  // 👤 cardShadow: 카드 상자 밑에 슥 깔리는 "그림자"를 만드는 요술 붓이에요.
  // 밤 모드일 때는 그림자가 조금 더 진하게 보이도록 계산해서 그려줘요.
  static BoxShadow cardShadow(bool isDark) => BoxShadow(
    color: Colors.black.withValues(
      alpha: isDark ? 0.4 : 0.08,
    ), // 밤(0.4)엔 진하고 낮(0.08)엔 아주 연해요.
    blurRadius: 15, // 그림자가 얼마나 부드럽게 퍼질지 정해요 (15만큼 부드럽게 번져요)
    offset: const Offset(0, 5), // 그림자를 아래로 5픽셀만큼 살짝 내려서 띄워진 느낌을 줘요.
  );

  // 🌈 cardGradient: 카드 상자를 한 가지 색이 아닌, 두 가지 색이 부드럽게 섞이게 칠하는 무지개 도구예요.
  static List<Color> cardGradient(bool isDark) =>
      isDark
          ? [
            const Color(0xFF1A1A24),
            const Color(0xFF14141A),
          ] // 🌙 밤에는 깊은 블랙/그레이 조합으로 차분하게
          : [
            Colors.white,
            const Color(0xFFF8F6F0),
          ]; // ☀️ 낮에는 하얀색에서 연한 아이보리색으로 슥~

  // ⭐ 항상 똑같이 쓸 포인트 강조색 두 가지예요.
  static const Color gold = Color(0xFFD4AF37); // 황금색
  static const Color midnightBlue = Color(0xFF2C3E50); // 어두운 남색

  // ☀️ 낮(밝은 모드)에 입을 전체 옷(ThemeData) 세트예요!
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light, // 밝은 낮 모드라고 알려줘요.
    primarySwatch: Colors.blueGrey, // 기본 색상 묶음은 차분한 청회색으로 해요.
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary, // 주된 색상
      onPrimary: Colors.white, // 주된 색상 위에 올라가는 글자색 (하얀색)
      secondary: _lightSecondary, // 포인트 색상
      onSecondary: Colors.white, // 포인트 색상 위에 올라가는 글자색
      surface: _lightSurface, // 물건 표면 색상
      onSurface: _lightText, // 표면 위에 올라가는 글자색
    ),
    scaffoldBackgroundColor: _lightBackground, // 전체 화면 바탕색
    cardColor: _lightCard, // 카드 상자 색상
    // 🏷️ 화면 맨 위 제목 줄(AppBar)의 낮 디자인이에요.
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground, // 제목 줄 배경도 전체 배경과 똑같이 맞춰요.
      foregroundColor: _lightPrimary, // 제목 글자나 아이콘 색상
      elevation: 0, // 입체감(그림자)을 없애서 납작하고 깔끔하게 만들어요.
      shadowColor: Colors.transparent, // 그림자 색상을 투명하게 지워요.
      // 📱 핸드폰 화면 맨 위의 시계와 배터리가 나오는 부분(상태바)을 설정해요.
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness:
            Brightness.dark, // 시계, 배터리 아이콘을 검은색으로 보이게 해요. (밝은 배경이니까요!)
        systemNavigationBarIconBrightness:
            Brightness.dark, // 맨 아래 네비게이션 아이콘도 검은색으로!
      ),
      titleTextStyle: TextStyle(
        color: _lightPrimary, // 제목 글자색
        fontSize: 22, // 글자 크기
        fontWeight: FontWeight.w600, // 글자 두께 (약간 두껍게)
        letterSpacing: 0.5, // 자간 (글자 사이 간격을 살짝 넓혀서 보기 편하게)
      ),
    ),

    // 📖 낮 모드의 글씨체(TextTheme) 상자예요.
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: _lightText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ), // 큰 제목
      titleMedium: TextStyle(
        color: _lightText,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ), // 중간 제목
      bodyLarge: TextStyle(color: _lightText, fontSize: 16), // 일반 본문 글자
      bodyMedium: TextStyle(
        color: _lightTextSecondary,
        fontSize: 14,
      ), // 작은 본문 글자
    ),

    iconTheme: const IconThemeData(color: _lightPrimary), // 기본 아이콘 색상
    // 📍 화면 맨 아래 탭 메뉴판(BottomNavigationBar)의 낮 디자인이에요.
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightCard, // 메뉴판 배경색
      selectedItemColor: _lightPrimary, // 선택된 메뉴는 진한 색으로 보여줘요.
      unselectedItemColor: _lightTextSecondary, // 선택되지 않은 메뉴는 연한 색으로 숨겨요.
      type: BottomNavigationBarType.fixed, // 메뉴들이 꼼짝하지 않고 제자리에 고정돼요.
      elevation: 8, // 메뉴판 위쪽으로 살짝 그림자가 지게 띄워요.
    ),
    // 📅 달력 디자인을 예쁘고 선명하게 만들어요
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: _lightCard,
      headerBackgroundColor: _lightPrimary,
      headerForegroundColor: Colors.white,
      dayStyle: TextStyle(color: _lightText),
      yearStyle: TextStyle(color: _lightText),
      todayForegroundColor: WidgetStatePropertyAll(_lightPrimary),
    ),
    // ⏰ 시계 디자인도 선명하게 만들어요
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: _lightCard,
      hourMinuteColor: _lightBackground,
      hourMinuteTextColor: _lightPrimary,
      dialHandColor: _lightPrimary,
      dialBackgroundColor: _lightBackground,
      dialTextColor: _lightText,
    ),
  );

  // 🌙 밤(어두운 모드)에 입을 전체 옷(ThemeData) 세트예요!
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // 어두운 밤 모드라고 알려줘요.
    primarySwatch: Colors.blueGrey, // 기본 색상 묶음
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary, // 주된 색상 (연한 크림색)
      onPrimary: _darkBackground, // 주된 색상 위에 올라가는 글자색 (어두운 색)
      secondary: _darkSecondary, // 포인트 색상 (황금색)
      onSecondary: _darkBackground,
      surface: _darkSurface,
      onSurface: _darkText,
    ),
    scaffoldBackgroundColor: _darkBackground, // 전체 화면 바탕색 (새까만 색)
    cardColor: _darkCard, // 카드 상자 색상
    // 🏷️ 화면 맨 위 제목 줄(AppBar)의 밤 디자인이에요.
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness:
            Brightness.light, // 시계, 배터리 아이콘을 하얗게 빛나게 해요. (배경이 까만색이니까요!)
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: _darkPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // 📖 밤 모드의 글씨체 상자예요. 글자들이 별빛처럼 하얗게 빛나요.
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: _darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: _darkText,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: _darkText, fontSize: 16),
      bodyMedium: TextStyle(color: _darkTextSecondary, fontSize: 14),
    ),

    iconTheme: const IconThemeData(color: _darkPrimary), // 기본 아이콘 색상
    // 📍 화면 맨 아래 탭 메뉴판(BottomNavigationBar)의 밤 디자인이에요.
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkSecondary, // 선택되면 예쁜 황금색으로 빛나요!
      unselectedItemColor: _darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // 밤에는 눈이 덜 아프게 그림자를 완전히 없애서 평평하게 만들어요.
    ),
    // 📅 달력 디자인을 밤에 어울리게 선명하게 만들어요
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: _darkCard,
      headerBackgroundColor: _darkSurface,
      headerForegroundColor: _darkPrimary,
      dayStyle: TextStyle(color: _darkText),
      yearStyle: TextStyle(color: _darkText),
      todayForegroundColor: WidgetStatePropertyAll(_darkSecondary),
    ),
    // ⏰ 시계 디자인도 밤에 어울리게 만들어요
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: _darkCard,
      hourMinuteColor: _darkSurface,
      hourMinuteTextColor: _darkPrimary,
      dialHandColor: _darkSecondary,
      dialBackgroundColor: _darkSurface,
      dialTextColor: _darkText,
    ),
  );
}
