import 'dart:convert';
import 'dart:io';
import 'database_service.dart';
import 'models/preference.dart';

class AiService {
  /// 네이탈 차트 기초 분석 — 음양/원소/퀄리티/에센셜 디그니티/하우스 강조 기반
  /// 내담자 고민 없이 차트 자체의 구조적 특성만 분석합니다.
  static Future<String> analyzeNatalChart({
    required List<String> placements,
    required List<String> aspects,
    bool isTimeUnknown = false,
  }) async {
    final pref = await DatabaseService.isar.preferences.get(0) ?? Preference();

    if (pref.apiKey.isEmpty &&
        !pref.customEndpoint.contains('localhost') &&
        !pref.customEndpoint.contains('127.0.0.1')) {
      throw Exception('API Key가 설정되어 있지 않습니다. 설정 화면에서 API Key를 등록해 주세요.');
    }

    final String analysisSteps = isTimeUnknown
        ? '''
[분석 순서]
1. 음양(Yin/Yang) 비율 — 차트 전체의 에너지 방향성 (외향 vs 내향)
2. 4원소 분포 (火/土/空/水) — 지배 원소와 결핍 원소, 그 심리적 의미
3. 퀄리티(Cardinal/Fixed/Mutable) 분포 — 행동 패턴과 변화 적응 방식
4. 에센셜 디그니티 — 지배행성의 강약 (Domicile/Exaltation/Detriment/Fall)
5. 핵심 어스펙트 패턴 — 가장 영향력 있는 각도 1~3개와 그 의미 (달의 각도는 오차가 클 수 있으니 주의해서 언급할 것)
6. 종합 — 이 사람의 핵심 주제 2~3가지 (삶에서 반복될 가능성이 높은 패턴)

*주의사항*: 출생 시간을 모르는 내담자이므로, 상승궁(Ascendant), 남중점(MC), 그리고 하우스(House) 영역에 대한 분석은 절대 포함하지 마세요.
'''
        : '''
[분석 순서]
1. 음양(Yin/Yang) 비율 — 차트 전체의 에너지 방향성 (외향 vs 내향)
2. 4원소 분포 (火/土/空/水) — 지배 원소와 결핍 원소, 그 심리적 의미
3. 퀄리티(Cardinal/Fixed/Mutable) 분포 — 행동 패턴과 변화 적응 방식
4. 에센셜 디그니티 — 지배행성의 강약 (Domicile/Exaltation/Detriment/Fall)
5. 강조된 하우스 — 어느 삶의 영역에 에너지가 집중되어 있는가
6. 핵심 어스펙트 패턴 — 가장 영향력 있는 각도 1~3개와 그 의미
7. 종합 — 이 사람의 핵심 주제 2~3가지 (삶에서 반복될 가능성이 높은 패턴)
''';

    final natalSystemPrompt = '''
당신은 전통 점성학의 원칙에 근거한 네이탈 차트 분석가입니다.
아래의 순서와 원칙에 따라 분석하세요.

[분석 원칙]
1. 기법으로 단정 짓지 말고, 경향성과 가능성으로 서술할 것.
2. 확증편향을 피하기 위해 장점과 도전 영역을 균형 있게 제시할 것.
3. 각 항목은 근거 행성/사인을 명시할 것.
4. 모든 행성과 사인, 어스펙트는 한글 텍스트 대신 반드시 기호(☉, ☽, ☿, ♀, ♂, ♃, ♄, ♅, ♆, ♇, ♈, ♉, ♊, ♋, ♌, ♍, ♎, ♏, ♐, ♑, ♒, ♓, ☌, ✶, □, △, ☍)로만 표기할 것.
5. 4원소를 표기할 때는 반드시 한자(火, 土, 空, 水)를 사용할 것. (풍(風)이 아닌 공(空)을 사용하세요.)

$analysisSteps

한국어로 작성. 전문 용어는 한국어(영어) 병기 사용. 분석 분량: 중간 정도(너무 짧지도 길지도 않게).
''';

    final userContent = '''
[Placements (행성 배치)]
${placements.join('\n')}

[Aspects (격각, 6도 이내 메이저)]
${aspects.join('\n')}
''';

    return await _callApi(
      systemPrompt: natalSystemPrompt,
      userContent: userContent,
      pref: pref,
    );
  }

  /// 상담 분석 — 내담자 고민과 차트를 연결하는 임상 분석
  static Future<AiAnalysisResult> analyzeConsultation({
    required List<String> placements,
    required List<String> aspects,
    required String complaint,
  }) async {
    final pref = await DatabaseService.isar.preferences.get(0) ?? Preference();

    if (pref.apiKey.isEmpty &&
        !pref.customEndpoint.contains('localhost') &&
        !pref.customEndpoint.contains('127.0.0.1')) {
      throw Exception('API Key가 설정되어 있지 않습니다. 설정 화면에서 API Key를 등록해 주세요.');
    }

    final userContent = '''
내담자 차트 데이터:
[Placements (차트 배치)]
${placements.join('\n')}

[Aspects (격각)]
${aspects.join('\n')}

내담자 고민 (Complaint):
$complaint
''';

    final opinion = await _callApi(
      systemPrompt: pref.systemPrompt,
      userContent: userContent,
      pref: pref,
    );

    final tags = extractTags(opinion);
    return AiAnalysisResult(opinion: opinion, recommendedTags: tags);
  }

  /// 공통 API 호출 로직
  static Future<String> _callApi({
    required String systemPrompt,
    required String userContent,
    required Preference pref,
  }) async {
    final isGemini = pref.customEndpoint.contains('generativelanguage');
    var modelNameSanitized = pref.modelName.trim().toLowerCase().replaceAll(' ', '-');

    if (modelNameSanitized.contains('gemini-1.5')) {
      modelNameSanitized = 'gemini-2.5-flash';
    }

    Uri uri;
    Map<String, String> headers;
    Map<String, dynamic> body;

    if (isGemini) {
      // Gemini Native REST API
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelNameSanitized:generateContent?key=${pref.apiKey}';
      uri = Uri.parse(url);
      headers = {
        'Content-Type': 'application/json',
      };
      body = {
        "systemInstruction": {
          "parts": [{"text": systemPrompt}]
        },
        "contents": [
          {
            "parts": [{"text": userContent}]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
        }
      };
    } else {
      // OpenAI Compatible API
      final endpoint = pref.customEndpoint.endsWith('/')
          ? pref.customEndpoint.substring(0, pref.customEndpoint.length - 1)
          : pref.customEndpoint;
      final url = '$endpoint/chat/completions';
      uri = Uri.parse(url);
      headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${pref.apiKey}',
      };
      body = {
        'model': modelNameSanitized,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userContent},
        ],
        'temperature': 0.7,
      };
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 60);

    try {
      final request = await client.postUrl(uri);
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
      request.add(utf8.encode(jsonEncode(body)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        
        if (isGemini) {
          final candidates = json['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>;
            final parts = content['parts'] as List<dynamic>;
            if (parts.isNotEmpty) {
              return parts[0]['text'] as String;
            }
          }
        } else {
          final choices = json['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            return choices[0]['message']['content'] as String;
          }
        }
        throw Exception('AI 응답 결과가 비어 있습니다.');
      } else {
        throw Exception('AI 요청 실패 (HTTP ${response.statusCode}):\n$responseBody');
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Extracts any hashtags (e.g. #결정장애) from the text.
  static List<String> extractTags(String text) {
    final tags = <String>[];
    final regExp = RegExp(r'#([ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9_-]+)');
    final matches = regExp.allMatches(text);
    for (final match in matches) {
      final tag = match.group(0);
      if (tag != null && !tags.contains(tag)) {
        tags.add(tag);
      }
    }
    return tags;
  }
}

class AiAnalysisResult {
  final String opinion;
  final List<String> recommendedTags;

  AiAnalysisResult({
    required this.opinion,
    required this.recommendedTags,
  });
}
