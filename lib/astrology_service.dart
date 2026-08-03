import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';

class FlutterAssetLoader with AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }
}

class AstrologyService {
  static bool _initialized = false;

  /// Initialize Swiss Ephemeris with the bundled assets.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final ephePath = '${docsDir.path}/ephe_files';
      await Directory(ephePath).create(recursive: true);

      await Sweph.init(
        epheAssets: const [
          'packages/sweph/assets/ephe/seas_18.se1',
          'packages/sweph/assets/ephe/sepl_18.se1',
          'packages/sweph/assets/ephe/semo_18.se1',
        ],
        assetLoader: FlutterAssetLoader(),
        epheFilesPath: ephePath,
      );
      _initialized = true;
    } catch (e) {
      print('Failed to initialize Sweph: $e');
      rethrow;
    }
  }

  /// Calculates the chart data and returns a list of placements and aspects.
  static Map<String, List<String>> calculateChart({
    required DateTime birthDate, // Local birth date (year, month, day)
    required String birthTime, // e.g. "14:30"
    required double latitude,
    required double longitude,
    required double timezoneOffset, // e.g. +9.0 for KST
  }) {
    if (!_initialized) {
      throw Exception(
        'AstrologyService is not initialized. Call init() first.',
      );
    }

    // 데이터 유실 방지: 위도/경도가 0.0일 경우 기본값(서울) 사용
    if (latitude == 0.0 && longitude == 0.0) {
      latitude = 37.5665;
      longitude = 126.9780;
    }

    // Parse time
    final effectiveTime =
        (birthTime == 'Unknown' || !birthTime.contains(':'))
            ? '12:00'
            : birthTime;
    final parts = effectiveTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 12;
    final minute = int.tryParse(parts[1]) ?? 0;

    final localDateTime = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      hour,
      minute,
    );

    // Convert local time to UTC
    final utcDateTime = localDateTime.subtract(
      Duration(minutes: (timezoneOffset * 60).round()),
    );
    final hourUtc =
        utcDateTime.hour +
        utcDateTime.minute / 60.0 +
        utcDateTime.second / 3600.0;

    // Calculate Julian Day in UT
    final jd = Sweph.swe_julday(
      utcDateTime.year,
      utcDateTime.month,
      utcDateTime.day,
      hourUtc,
      CalendarType.SE_GREG_CAL,
    );

    final placements = <String>[];
    final aspects = <String>[];

    // Define main planetary/heavenly bodies and asteroids
    final bodies = {
      'Sun': HeavenlyBody.SE_SUN,
      'Moon': HeavenlyBody.SE_MOON,
      'Mercury': HeavenlyBody.SE_MERCURY,
      'Venus': HeavenlyBody.SE_VENUS,
      'Mars': HeavenlyBody.SE_MARS,
      'Jupiter': HeavenlyBody.SE_JUPITER,
      'Saturn': HeavenlyBody.SE_SATURN,
      'Uranus': HeavenlyBody.SE_URANUS,
      'Neptune': HeavenlyBody.SE_NEPTUNE,
      'Pluto': HeavenlyBody.SE_PLUTO,
      'Chiron': HeavenlyBody.SE_CHIRON,
      'NorthNode': HeavenlyBody.SE_TRUE_NODE,
      'Lilith': HeavenlyBody.SE_MEAN_APOG,
      'Ceres': HeavenlyBody.SE_CERES,
      'Pallas': HeavenlyBody.SE_PALLAS,
      'Juno': HeavenlyBody.SE_JUNO,
      'Vesta': HeavenlyBody.SE_VESTA,
    };

    // 1. Calculate Houses & Angles
    // We use Placidus (Hsys.P) by default
    final houseData = Sweph.swe_houses(jd, latitude, longitude, Hsys.P);
    final cusps = houseData.cusps; // 1-indexed (index 1 is 1st house cusp)
    final ascendant = houseData.ascmc[0];
    final mc = houseData.ascmc[1];

    placements.add('Ascendant in ${getZodiacSign(ascendant)}');
    placements.add('MC in ${getZodiacSign(mc)}');

    // 2. Calculate Planets
    final longitudes = <String, double>{};
    longitudes['Ascendant'] = ascendant;
    longitudes['MC'] = mc;

    for (final entry in bodies.entries) {
      final name = entry.key;
      final body = entry.value;

      final calc = Sweph.swe_calc_ut(jd, body, SwephFlag.SEFLG_SWIEPH);
      final lon = calc.longitude;
      longitudes[name] = lon;

      // Check Retrograde
      if (calc.speedInLongitude < 0) {
        placements.add('$name Retrograde');
      }

      // Zodiac Sign placement
      final sign = getZodiacSign(lon);
      placements.add('$name in $sign');

      // House placement
      final house = getHouseForLongitude(lon, cusps);
      placements.add('$name in $house House');
    }

    // South Node is exactly 180 degrees opposite the North Node
    final northNodeLon = longitudes['NorthNode'] ?? 0.0;
    final southNodeLon = (northNodeLon + 180.0) % 360;
    longitudes['SouthNode'] = southNodeLon;
    placements.add('SouthNode in ${getZodiacSign(southNodeLon)}');
    placements.add(
      'SouthNode in ${getHouseForLongitude(southNodeLon, cusps)} House',
    );

    // Calculate Part of Fortune (PoF)
    final sunLon = longitudes['Sun'] ?? 0.0;
    final moonLon = longitudes['Moon'] ?? 0.0;
    final ascLon = ascendant;
    final sunHouse = getHouseForLongitude(sunLon, cusps);
    final isDayBirth = sunHouse >= 7 && sunHouse <= 12;
    final pof =
        isDayBirth
            ? (ascLon + moonLon - sunLon) % 360
            : (ascLon - moonLon + sunLon) % 360;
    longitudes['Fortune'] = pof;
    placements.add('Fortune in ${getZodiacSign(pof)}');
    placements.add('Fortune in ${getHouseForLongitude(pof, cusps)} House');

    // 3. Calculate Aspects
    // 메이저 행성 및 주요 감수점들만 어스펙트 계산에 포함하여 너무 많은 결과가 나오지 않도록 제한
    final majorAspectBodies = [
      'Sun',
      'Moon',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Uranus',
      'Neptune',
      'Pluto',
      'Ascendant',
      'MC',
    ];

    final aspectList =
        longitudes.keys.where((k) => majorAspectBodies.contains(k)).toList();
    for (int i = 0; i < aspectList.length; i++) {
      for (int j = i + 1; j < aspectList.length; j++) {
        final b1 = aspectList[i];
        final b2 = aspectList[j];
        final lon1 = longitudes[b1]!;
        final lon2 = longitudes[b2]!;

        final aspectName = getAspect(lon1, lon2);
        if (aspectName != null) {
          final sortedNames = [b1, b2]..sort();
          aspects.add('${sortedNames[0]}-${sortedNames[1]}-$aspectName');
        }
      }
    }

    return {'placements': placements, 'aspects': aspects};
  }

  /// Calculates the raw degrees of planets and house cusps for drawing the visual chart.
  static Map<String, dynamic> calculateNatalData({
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    required double timezoneOffset,
  }) {
    if (!_initialized) {
      throw Exception(
        'AstrologyService is not initialized. Call init() first.',
      );
    }

    // 데이터 유실 방지: 위도/경도가 0.0일 경우 기본값(서울) 사용
    if (latitude == 0.0 && longitude == 0.0) {
      latitude = 37.5665;
      longitude = 126.9780;
    }

    int hour = 12;
    int minute = 0;

    if (birthTime != 'Unknown' && birthTime.contains(':')) {
      final parts = birthTime.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    }

    final unadjustedUtc = DateTime.utc(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      hour,
      minute,
    );

    final utcDateTime = unadjustedUtc.subtract(
      Duration(minutes: (timezoneOffset * 60).round()),
    );
    final hourUtc =
        utcDateTime.hour +
        utcDateTime.minute / 60.0 +
        utcDateTime.second / 3600.0;

    final jd = Sweph.swe_julday(
      utcDateTime.year,
      utcDateTime.month,
      utcDateTime.day,
      hourUtc,
      CalendarType.SE_GREG_CAL,
    );

    final houseData = Sweph.swe_houses(jd, latitude, longitude, Hsys.P);
    final cusps = houseData.cusps; // 1-indexed list of size 13
    final ascendant = houseData.ascmc[0];
    final mc = houseData.ascmc[1];

    final bodies = {
      'Sun': HeavenlyBody.SE_SUN,
      'Moon': HeavenlyBody.SE_MOON,
      'Mercury': HeavenlyBody.SE_MERCURY,
      'Venus': HeavenlyBody.SE_VENUS,
      'Mars': HeavenlyBody.SE_MARS,
      'Jupiter': HeavenlyBody.SE_JUPITER,
      'Saturn': HeavenlyBody.SE_SATURN,
      'Uranus': HeavenlyBody.SE_URANUS,
      'Neptune': HeavenlyBody.SE_NEPTUNE,
      'Pluto': HeavenlyBody.SE_PLUTO,
      'Chiron': HeavenlyBody.SE_CHIRON,
      'NorthNode': HeavenlyBody.SE_TRUE_NODE,
      'Lilith': HeavenlyBody.SE_MEAN_APOG,
      'Ceres': HeavenlyBody.SE_CERES,
      'Pallas': HeavenlyBody.SE_PALLAS,
      'Juno': HeavenlyBody.SE_JUNO,
      'Vesta': HeavenlyBody.SE_VESTA,
    };

    final longitudes = <String, double>{};
    longitudes['Ascendant'] = ascendant;
    longitudes['MC'] = mc;

    for (final entry in bodies.entries) {
      final name = entry.key;
      final body = entry.value;
      final calc = Sweph.swe_calc_ut(jd, body, SwephFlag.SEFLG_SWIEPH);
      longitudes[name] = calc.longitude;
    }

    // South Node is exactly 180 degrees opposite the North Node
    final northNodeLon = longitudes['NorthNode'] ?? 0.0;
    longitudes['SouthNode'] = (northNodeLon + 180.0) % 360;

    // Calculate Part of Fortune (PoF)
    final sunLon = longitudes['Sun'] ?? 0.0;
    final moonLon = longitudes['Moon'] ?? 0.0;
    final ascLon = ascendant;

    // Day birth (Sun above horizon / Houses 7-12) vs Night birth (Sun below horizon / Houses 1-6)
    final sunHouse = _getHouseForLongitude(sunLon, cusps);
    final isDayBirth = sunHouse >= 7 && sunHouse <= 12;
    if (isDayBirth) {
      longitudes['Fortune'] = (ascLon + moonLon - sunLon) % 360;
    } else {
      longitudes['Fortune'] = (ascLon - moonLon + sunLon) % 360;
    }

    return {'longitudes': longitudes, 'cusps': cusps};
  }

  static int _getHouseForLongitude(double lon, List<double> cusps) {
    if (cusps.length < 13) return 1;
    for (int h = 1; h <= 12; h++) {
      final c1 = cusps[h];
      final c2 = cusps[h == 12 ? 1 : h + 1];
      if (c2 > c1) {
        if (lon >= c1 && lon < c2) return h;
      } else {
        if (lon >= c1 || lon < c2) return h;
      }
    }
    return 1;
  }

  /// Normalize degrees to 0-360 and find the Zodiac Sign
  static String getZodiacSign(double longitude) {
    const signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ];
    final norm = longitude % 360;
    final idx = (norm / 30).floor();
    return signs[idx];
  }

  /// Get the house number for a planet longitude based on Placidus cusps
  static int getHouseForLongitude(double longitude, List<double> cusps) {
    // cusps is a 1-indexed list of size 13
    for (int h = 1; h <= 12; h++) {
      final start = cusps[h];
      final end = cusps[h == 12 ? 1 : h + 1];

      if (start < end) {
        if (longitude >= start && longitude < end) {
          return h;
        }
      } else {
        // Crosses the 360-degree boundary
        if (longitude >= start || longitude < end) {
          return h;
        }
      }
    }
    return 1; // Fallback
  }

  /// Calculate the angular distance between two longitudes
  static double angularDistance(double lon1, double lon2) {
    final diff = (lon1 - lon2).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  /// Check if two longitudes form a major aspect
  static String? getAspect(double lon1, double lon2) {
    final dist = angularDistance(lon1, lon2);

    // Aspect definitions with orbs (일괄 6도로 수정)
    const aspects = [
      {'name': 'Conjunction', 'angle': 0.0, 'orb': 6.0},
      {'name': 'Sextile', 'angle': 60.0, 'orb': 6.0},
      {'name': 'Square', 'angle': 90.0, 'orb': 6.0},
      {'name': 'Trine', 'angle': 120.0, 'orb': 6.0},
      {'name': 'Opposition', 'angle': 180.0, 'orb': 6.0},
    ];

    for (final aspect in aspects) {
      final angle = aspect['angle'] as double;
      final orb = aspect['orb'] as double;

      if ((dist - angle).abs() <= orb) {
        return aspect['name'] as String;
      }
    }

    return null;
  }

  // ── 행성 기호 (화면 표시용) ──────────────────────────────────────────────
  static const Map<String, String> planetSymbol = {
    'Sun': '☉\uFE0E',
    'Moon': '☽\uFE0E',
    'Mercury': '☿',
    'Venus': '♀',
    'Mars': '♂',
    'Jupiter': '♃',
    'Saturn': '♄',
    'Uranus': '♅',
    'Neptune': '♆',
    'Pluto': '♇',
    'Chiron': '⚷',
    'NorthNode': '☊',
    'SouthNode': '☋',
    'Fortune': '⊗',
    'Lilith': '⚸',
    'Ceres': '⚳',
    'Pallas': '⚴',
    'Juno': '⚵',
    'Vesta': '⚶',
    'Ascendant': 'ASC',
    'MC': 'MC',
  };

  // ── 한국어 라벨 (검색·태그용 텍스트 전용) ──────────────────────────────
  static const Map<String, String> planetKorean = {
    'Sun': '태양',
    'Moon': '달',
    'Mercury': '수성',
    'Venus': '금성',
    'Mars': '화성',
    'Jupiter': '목성',
    'Saturn': '토성',
    'Uranus': '천왕성',
    'Neptune': '해왕성',
    'Pluto': '명왕성',
    'Chiron': '키론',
    'NorthNode': '북노드',
    'SouthNode': '남노드',
    'Fortune': '포춘',
    'Lilith': '릴리스',
    'Ceres': '세레스',
    'Pallas': '팔라스',
    'Juno': '주노',
    'Vesta': '베스타',
    'Ascendant': 'ASC',
    'MC': 'MC',
  };

  // ── 황도 12궁 기호 ────────────────────────────────────────────────────────
  static const Map<String, String> zodiacSymbol = {
    'Aries': '♈',
    'Taurus': '♉',
    'Gemini': '♊',
    'Cancer': '♋',
    'Leo': '♌',
    'Virgo': '♍',
    'Libra': '♎',
    'Scorpio': '♏',
    'Sagittarius': '♐',
    'Capricorn': '♑',
    'Aquarius': '♒',
    'Pisces': '♓',
  };

  static const Map<String, String> zodiacKorean = {
    'Aries': '양자리',
    'Taurus': '황소자리',
    'Gemini': '쌍둥이자리',
    'Cancer': '게자리',
    'Leo': '사자자리',
    'Virgo': '처녀자리',
    'Libra': '천칭자리',
    'Scorpio': '전갈자리',
    'Sagittarius': '사수자리',
    'Capricorn': '염소자리',
    'Aquarius': '물병자리',
    'Pisces': '물고기자리',
  };

  // ── 어스펙트 기호 ─────────────────────────────────────────────────────────
  static const Map<String, String> aspectSymbol = {
    'Conjunction': '☌',
    'Sextile': '✶',
    'Square': '□',
    'Trine': '△',
    'Opposition': '☍',
  };

  // ── 화면 표시: 배치 → 기호 ───────────────────────────────────────────────
  /// e.g. "Sun in Leo" → "☉ ♌"  |  "Sun in 9th House" → "☉ 9ℎ"  |  "Mercury Retrograde" → "☿ ℞"
  static String translatePlacement(String placement) {
    if (placement.endsWith('Retrograde')) {
      final planet = placement.split(' ')[0];
      return '${planetSymbol[planet] ?? planet} ℞';
    }
    if (placement.toLowerCase().contains('house')) {
      if (placement.toLowerCase().contains(' in ')) {
        final parts = placement.split(RegExp(r'\s+in\s+', caseSensitive: false));
        final left = parts[0];
        final right = parts[1];
        
        if (right.toLowerCase().contains('house')) {
          final planet = left;
          final house = right.replaceAll(RegExp(r'(?:st|nd|rd|th)?\s*house', caseSensitive: false), '').trim();
          return '${planetSymbol[planet] ?? planet} ${house}ℎ';
        } else {
          final house = left.replaceAll(RegExp(r'(?:st|nd|rd|th)?\s*house', caseSensitive: false), '').trim();
          final sign = right;
          return '${house}ℎ ${zodiacSymbol[sign] ?? sign}';
        }
      } else {
        final house = placement.replaceAll(RegExp(r'(?:st|nd|rd|th)?\s*house', caseSensitive: false), '').trim();
        return '${house}ℎ';
      }
    }
    if (placement.toLowerCase().contains(' in ')) {
      final parts = placement.split(RegExp(r'\s+in\s+', caseSensitive: false));
      final planet = parts[0];
      final sign = parts[1];
      return '${planetSymbol[planet] ?? planet} ${zodiacSymbol[sign] ?? sign}';
    }
    return placement;
  }

  /// e.g. "Moon-Saturn-Square" → "☽ □ ♄"
  static String translateAspect(String aspect) {
    final parts = aspect.split('-');
    if (parts.length < 3) return aspect;
    final p1 = parts[0];
    final p2 = parts[1];
    final type = parts[2];
    return '${planetSymbol[p1] ?? p1} ${aspectSymbol[type] ?? type} ${planetSymbol[p2] ?? p2}';
  }

  // ── 차트 프로필 분석 (메이저 10행성 + Asc = 11개 기준) ───────────────────
  static const List<String> _majorBodies = [
    'Sun',
    'Moon',
    'Mercury',
    'Venus',
    'Mars',
    'Jupiter',
    'Saturn',
    'Uranus',
    'Neptune',
    'Pluto',
    'Ascendant',
  ];

  static const Map<String, String> _signElement = {
    'Aries': '화',
    'Leo': '화',
    'Sagittarius': '화',
    'Taurus': '토',
    'Virgo': '토',
    'Capricorn': '토',
    'Gemini': '공',
    'Libra': '공',
    'Aquarius': '공',
    'Cancer': '수',
    'Scorpio': '수',
    'Pisces': '수',
  };

  static const Map<String, String> _signQuality = {
    'Aries': '카디날',
    'Cancer': '카디날',
    'Libra': '카디날',
    'Capricorn': '카디날',
    'Taurus': '픽스드',
    'Leo': '픽스드',
    'Scorpio': '픽스드',
    'Aquarius': '픽스드',
    'Gemini': '뮤터블',
    'Virgo': '뮤터블',
    'Sagittarius': '뮤터블',
    'Pisces': '뮤터블',
  };

  static const Set<String> _yangSigns = {
    'Aries',
    'Gemini',
    'Leo',
    'Libra',
    'Sagittarius',
    'Aquarius',
  };

  /// 원소 × 퀄리티 → 사인 룩업 테이블
  static const Map<String, Map<String, String>> _elementQualitySign = {
    '화': {'카디날': 'Aries', '픽스드': 'Leo', '뮤터블': 'Sagittarius'},
    '토': {'카디날': 'Capricorn', '픽스드': 'Taurus', '뮤터블': 'Virgo'},
    '공': {'카디날': 'Libra', '픽스드': 'Aquarius', '뮤터블': 'Gemini'},
    '수': {'카디날': 'Cancer', '픽스드': 'Scorpio', '뮤터블': 'Pisces'},
  };

  /// 11개 행성 기준 음양/화토공수/퀄리티 분포 반환
  /// 대표 사인 = 지배 원소(공동 1위 모두) × 지배 퀄리티 교차점
  static Map<String, dynamic> analyzeChartProfile(
    Map<String, double> longitudes,
  ) {
    int fire = 0, earth = 0, air = 0, water = 0;
    int yin = 0, yang = 0;
    int cardinal = 0, fixed = 0, mutable_ = 0;

    for (final body in _majorBodies) {
      final lon = longitudes[body];
      if (lon == null) continue;
      final sign = getZodiacSign(lon);

      // 원소
      final el = _signElement[sign] ?? '';
      if (el == '화')
        fire++;
      else if (el == '토')
        earth++;
      else if (el == '공')
        air++;
      else if (el == '수')
        water++;

      // 음양
      if (_yangSigns.contains(sign))
        yang++;
      else
        yin++;

      // 퀄리티
      final q = _signQuality[sign] ?? '';
      if (q == '카디날')
        cardinal++;
      else if (q == '픽스드')
        fixed++;
      else
        mutable_++;
    }

    final elementCounts = {'화': fire, '토': earth, '공': air, '수': water};
    final qualityCounts = {'카디날': cardinal, '픽스드': fixed, '뮤터블': mutable_};

    // 지배 원소 최댓값 (공동 1위 모두 포함)
    final maxEl = elementCounts.values.reduce((a, b) => a > b ? a : b);
    final dominantElements =
        elementCounts.entries
            .where((e) => e.value == maxEl)
            .map((e) => e.key)
            .toList();

    // 지배 퀄리티
    final dominantQuality =
        qualityCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    // 대표 사인 = 지배 원소(들) × 지배 퀄리티
    final repSigns =
        dominantElements
            .map((el) => _elementQualitySign[el]?[dominantQuality] ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

    final repSignsKorean =
        repSigns
            .map((s) => '${zodiacSymbol[s] ?? ''} ${zodiacKorean[s] ?? s}')
            .toList();

    return {
      'fire': fire, 'earth': earth, 'air': air, 'water': water,
      'yin': yin, 'yang': yang,
      'cardinal': cardinal, 'fixed': fixed, 'mutable': mutable_,
      'dominantElements': dominantElements,
      'dominantQuality': dominantQuality,
      'repSigns': repSignsKorean, // e.g. ['♑ 염소자리', '♋ 게자리']
    };
  }

  /// Calculates the progressed Sun-Moon angle and returns the progressed phase (season, phase name, description).
  static Map<String, dynamic> calculateProgressedLunarPhase({
    required DateTime birthDate,
    required String birthTime,
    required double timezoneOffset,
  }) {
    if (!_initialized) {
      throw Exception(
        'AstrologyService is not initialized. Call init() first.',
      );
    }

    // 1. Calculate UTC birth time
    final effectiveTime =
        (birthTime == 'Unknown' || !birthTime.contains(':'))
            ? '12:00'
            : birthTime;
    final parts = effectiveTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 12;
    final minute = int.tryParse(parts[1]) ?? 0;
    final localDateTime = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      hour,
      minute,
    );
    final utcDateTime = localDateTime.subtract(
      Duration(minutes: (timezoneOffset * 60).round()),
    );

    // 2. Calculate age in years
    final nowUtc = DateTime.now().toUtc();
    final ageInDays = nowUtc.difference(utcDateTime).inDays;
    final ageInYears = ageInDays / 365.242199; // Mean tropical year length

    // 3. Progressed Date: 1 year of life = 1 day (24 hours) of time
    final progressedUtc = utcDateTime.add(
      Duration(seconds: (ageInYears * 24 * 60 * 60).round()),
    );
    final hourUtc =
        progressedUtc.hour +
        progressedUtc.minute / 60.0 +
        progressedUtc.second / 3600.0;

    final jd = Sweph.swe_julday(
      progressedUtc.year,
      progressedUtc.month,
      progressedUtc.day,
      hourUtc,
      CalendarType.SE_GREG_CAL,
    );

    // 4. Calculate progressed Sun & Moon
    final calcSun = Sweph.swe_calc_ut(
      jd,
      HeavenlyBody.SE_SUN,
      SwephFlag.SEFLG_SWIEPH,
    );
    final calcMoon = Sweph.swe_calc_ut(
      jd,
      HeavenlyBody.SE_MOON,
      SwephFlag.SEFLG_SWIEPH,
    );

    final sunLon = calcSun.longitude;
    final moonLon = calcMoon.longitude;

    // 5. Angle difference (Moon - Sun)
    final diff = (moonLon - sunLon) % 360;

    // 6. Map to phase & season
    String phaseName = '';
    String seasonName = '';
    String description = '';
    String icon = '';

    if (diff >= 0 && diff < 45) {
      phaseName = 'New Moon';
      seasonName = '봄(시작)';
      description = '새로운 씨앗을 뿌리고 삶의 방향성을 새롭게 정립하는 시기';
      icon = '🌑';
    } else if (diff >= 45 && diff < 90) {
      phaseName = 'Crescent Moon';
      seasonName = '봄(성장)';
      description = '새로운 방향에 맞춰 구체적인 계획을 설계하고 전진하는 시기';
      icon = '🌒';
    } else if (diff >= 90 && diff < 135) {
      phaseName = 'First Quarter';
      seasonName = '여름(초기)';
      description = '장애물을 돌파하고 과감하게 행동을 실행에 옮기는 시기';
      icon = '🌓';
    } else if (diff >= 135 && diff < 180) {
      phaseName = 'Gibbous Moon';
      seasonName = '여름(성숙)';
      description = '행동의 성과를 거두기 직전, 세밀하게 디테일을 조율하고 보완하는 시기';
      icon = '🌔';
    } else if (diff >= 180 && diff < 225) {
      phaseName = 'Full Moon';
      seasonName = '가을(초기)';
      description = '노력했던 일의 결과가 만천하에 드러나고 객관적 성찰이 일어나는 시기';
      icon = '🌕';
    } else if (diff >= 225 && diff < 270) {
      phaseName = 'Disseminating Moon';
      seasonName = '가을(성숙)';
      description = '자신의 깨달음과 성과를 주변 사람들과 나누고 공유하는 시기';
      icon = '🌖';
    } else if (diff >= 270 && diff < 315) {
      phaseName = 'Last Quarter';
      seasonName = '겨울(초기)';
      description = '불필요한 욕심이나 낡은 구조를 점진적으로 구조조정하고 내려놓는 시기';
      icon = '🌗';
    } else {
      phaseName = 'Balsamic Moon';
      seasonName = '겨울(마지막)';
      description = '봄이 오기 전 마지막 정화의 시기. 새로운 씨앗을 맞이하기 위해 비우고 휴식하는 단계';
      icon = '🌘';
    }

    return {
      'age': ageInYears,
      'diffDegrees': diff,
      'phaseName': phaseName,
      'seasonName': seasonName,
      'description': description,
      'icon': icon,
      'progressedDate': progressedUtc,
    };
  }

  /// Calculates transit planetary longitudes for the current UTC time.
  static Map<String, double> calculateTransitLongitudes() {
    if (!_initialized) {
      throw Exception(
        'AstrologyService is not initialized. Call init() first.',
      );
    }

    final nowUtc = DateTime.now().toUtc();
    final hourUtc = nowUtc.hour + nowUtc.minute / 60.0 + nowUtc.second / 3600.0;
    final jd = Sweph.swe_julday(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
      hourUtc,
      CalendarType.SE_GREG_CAL,
    );

    final bodies = {
      'Sun': HeavenlyBody.SE_SUN,
      'Moon': HeavenlyBody.SE_MOON,
      'Mercury': HeavenlyBody.SE_MERCURY,
      'Venus': HeavenlyBody.SE_VENUS,
      'Mars': HeavenlyBody.SE_MARS,
      'Jupiter': HeavenlyBody.SE_JUPITER,
      'Saturn': HeavenlyBody.SE_SATURN,
      'Uranus': HeavenlyBody.SE_URANUS,
      'Neptune': HeavenlyBody.SE_NEPTUNE,
      'Pluto': HeavenlyBody.SE_PLUTO,
      'Chiron': HeavenlyBody.SE_CHIRON,
      'NorthNode': HeavenlyBody.SE_TRUE_NODE,
    };

    final longitudes = <String, double>{};
    for (final entry in bodies.entries) {
      final name = entry.key;
      final body = entry.value;
      final calc = Sweph.swe_calc_ut(jd, body, SwephFlag.SEFLG_SWIEPH);
      longitudes[name] = calc.longitude;
    }
    final northNodeLon = longitudes['NorthNode'] ?? 0.0;
    longitudes['SouthNode'] = (northNodeLon + 180.0) % 360;

    return longitudes;
  }

  /// Calculates Transit-to-Natal aspects.
  static List<String> calculateTransitToNatalAspects({
    required Map<String, double> natalLongitudes,
    required Map<String, double> transitLongitudes,
    double maxOrb = 3.0,
  }) {
    final activeTransits = <String>[];

    final transitPlanets = [
      'Sun',
      'Moon',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Uranus',
      'Neptune',
      'Pluto',
      'Chiron',
      'NorthNode',
      'SouthNode',
    ];
    final natalPlanets = [
      'Sun',
      'Moon',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Uranus',
      'Neptune',
      'Pluto',
      'Chiron',
      'NorthNode',
      'SouthNode',
      'Ascendant',
      'MC',
    ];

    const aspects = [
      {'name': 'Conjunction', 'angle': 0.0},
      {'name': 'Sextile', 'angle': 60.0},
      {'name': 'Square', 'angle': 90.0},
      {'name': 'Trine', 'angle': 120.0},
      {'name': 'Opposition', 'angle': 180.0},
    ];

    for (final tp in transitPlanets) {
      final tLon = transitLongitudes[tp];
      if (tLon == null) continue;

      for (final np in natalPlanets) {
        final nLon = natalLongitudes[np];
        if (nLon == null) continue;

        final dist = angularDistance(tLon, nLon);
        for (final aspect in aspects) {
          final angle = aspect['angle'] as double;
          final diff = (dist - angle).abs();
          if (diff <= maxOrb) {
            activeTransits.add('$tp-$np-${aspect['name']}');
          }
        }
      }
    }

    return activeTransits;
  }

  /// Calculates Synastry aspects and house overlay between Person A and Person B.
  static Map<String, dynamic> calculateSynastryData({
    required Map<String, double> longitudesA,
    required List<double> cuspsA,
    required Map<String, double> longitudesB,
    required List<double> cuspsB,
  }) {
    final synastryAspects = <String>[];
    final majorBodies = [
      'Sun', 'Moon', 'Mercury', 'Venus', 'Mars',
      'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto',
      'Ascendant', 'MC'
    ];

    // 1. Inter-aspects between Person A and Person B
    for (final bA in majorBodies) {
      final lonA = longitudesA[bA];
      if (lonA == null) continue;
      for (final bB in majorBodies) {
        final lonB = longitudesB[bB];
        if (lonB == null) continue;

        final aspectName = getAspect(lonA, lonB);
        if (aspectName != null) {
          synastryAspects.add('$bA(A)-$bB(B)-$aspectName');
        }
      }
    }

    // 2. House overlays: Person A's planets in Person B's houses & Person B's planets in Person A's houses
    final aInBHouses = <String, int>{};
    final bInAHouses = <String, int>{};

    for (final entry in longitudesA.entries) {
      if (cuspsB.length >= 13) {
        aInBHouses[entry.key] = getHouseForLongitude(entry.value, cuspsB);
      }
    }

    for (final entry in longitudesB.entries) {
      if (cuspsA.length >= 13) {
        bInAHouses[entry.key] = getHouseForLongitude(entry.value, cuspsA);
      }
    }

    return {
      'synastryAspects': synastryAspects,
      'personAInPersonBHouses': aInBHouses,
      'personBInPersonAHouses': bInAHouses,
    };
  }

  /// Calculates Composite midpoints between Person A and Person B longitudes and cusps.
  static Map<String, dynamic> calculateCompositeData({
    required Map<String, double> longitudesA,
    required List<double> cuspsA,
    required Map<String, double> longitudesB,
    required List<double> cuspsB,
  }) {
    final compositeLongitudes = <String, double>{};
    final keys = longitudesA.keys.where((k) => longitudesB.containsKey(k));

    for (final key in keys) {
      final lonA = longitudesA[key]!;
      final lonB = longitudesB[key]!;
      
      // Calculate shortest arc midpoint
      double diff = (lonA - lonB).abs();
      double midpoint;
      if (diff <= 180.0) {
        midpoint = (lonA + lonB) / 2.0;
      } else {
        midpoint = ((lonA + lonB + 360.0) / 2.0) % 360.0;
      }
      compositeLongitudes[key] = midpoint;
    }

    // Midpoints for cusps (if available)
    final compositeCusps = <double>[0.0]; // 1-indexed
    if (cuspsA.length >= 13 && cuspsB.length >= 13) {
      for (int h = 1; h <= 12; h++) {
        final cA = cuspsA[h];
        final cB = cuspsB[h];
        double diff = (cA - cB).abs();
        double mid;
        if (diff <= 180.0) {
          mid = (cA + cB) / 2.0;
        } else {
          mid = ((cA + cB + 360.0) / 2.0) % 360.0;
        }
        compositeCusps.add(mid);
      }
    }

    // Composite Placements & Aspects
    final placements = <String>[];
    final aspects = <String>[];

    for (final entry in compositeLongitudes.entries) {
      final name = entry.key;
      final lon = entry.value;
      final sign = getZodiacSign(lon);
      placements.add('$name in $sign');
      if (compositeCusps.length >= 13) {
        final house = getHouseForLongitude(lon, compositeCusps);
        placements.add('$name in $house House');
      }
    }

    final majorAspectBodies = [
      'Sun', 'Moon', 'Mercury', 'Venus', 'Mars',
      'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto',
      'Ascendant', 'MC'
    ];
    final aspectList = compositeLongitudes.keys.where((k) => majorAspectBodies.contains(k)).toList();

    for (int i = 0; i < aspectList.length; i++) {
      for (int j = i + 1; j < aspectList.length; j++) {
        final b1 = aspectList[i];
        final b2 = aspectList[j];
        final lon1 = compositeLongitudes[b1]!;
        final lon2 = compositeLongitudes[b2]!;

        final aspectName = getAspect(lon1, lon2);
        if (aspectName != null) {
          final sortedNames = [b1, b2]..sort();
          aspects.add('${sortedNames[0]}-${sortedNames[1]}-$aspectName');
        }
      }
    }

    return {
      'compositeLongitudes': compositeLongitudes,
      'compositeCusps': compositeCusps,
      'placements': placements,
      'aspects': aspects,
    };
  }
}

