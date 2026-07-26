import 'package:isar/isar.dart';

part 'client.g.dart';

@collection
class Client {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  late DateTime birthDate; // Local date of birth (YYYY-MM-DD)
  late String birthTime; // e.g. "14:30"
  late String birthPlace; // e.g. "Seoul"

  late double latitude;
  late double longitude;
  late double timezoneOffset; // e.g. +9.0 for KST

  // Astrological placements calculated at birth:
  // e.g. ["Sun in Leo", "Moon in Taurus", "Ascendant in Scorpio", "Sun in 9th House"]
  late List<String> placements;

  // Astrological aspects:
  // e.g. ["Sun conjunct Mercury", "Moon square Saturn"]
  late List<String> aspects;

  late String note;

  // ── Phase 2: 임상 관찰 노트 ──────────────────────────────────────────
  // AI 분석을 먼저 보고 난 후 직접 기록하는 관찰 데이터

  /// 실제 관찰 내용 (자유 서술)
  String clinicalObservation = '';

  /// AI 분석과의 일치도: 'match' | 'partial' | 'mismatch' | ''
  String aiMatchLevel = '';

  /// 패턴 태그 (Phase 3 검색용) — e.g. ['#아버지이슈', '#직장갈등']
  List<String> clinicalTags = [];

  /// 재검토 필요 여부
  bool needsReview = false;

  /// AI가 작성한 기초 분석 결과
  String aiAnalysisResult = '';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birthDate': birthDate.toIso8601String(),
    'birthTime': birthTime,
    'birthPlace': birthPlace,
    'latitude': latitude,
    'longitude': longitude,
    'timezoneOffset': timezoneOffset,
    'placements': placements,
    'aspects': aspects,
    'note': note,
    'clinicalObservation': clinicalObservation,
    'aiMatchLevel': aiMatchLevel,
    'clinicalTags': clinicalTags,
    'needsReview': needsReview,
    'aiAnalysisResult': aiAnalysisResult,
  };

  static Client fromJson(Map<String, dynamic> json) {
    final client =
        Client()
          ..id = (json['id'] as num).toInt()
          ..name = json['name'] as String
          ..birthDate = DateTime.parse(json['birthDate'] as String)
          ..birthTime = json['birthTime'] as String
          ..birthPlace = json['birthPlace'] as String
          ..latitude = (json['latitude'] as num).toDouble()
          ..longitude = (json['longitude'] as num).toDouble()
          ..timezoneOffset = (json['timezoneOffset'] as num).toDouble()
          ..placements = List<String>.from(json['placements'] as List)
          ..aspects = List<String>.from(json['aspects'] as List)
          ..note = json['note'] as String
          ..clinicalObservation = json['clinicalObservation'] as String? ?? ''
          ..aiMatchLevel = json['aiMatchLevel'] as String? ?? ''
          ..clinicalTags = List<String>.from(
            json['clinicalTags'] as List? ?? [],
          )
          ..needsReview = json['needsReview'] as bool? ?? false
          ..aiAnalysisResult = json['aiAnalysisResult'] as String? ?? '';
    return client;
  }
}
