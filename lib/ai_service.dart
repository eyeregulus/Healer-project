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

    final String analysisSteps =
        isTimeUnknown
            ? '''
[분석 순서]
1. 음양(Yin/Yang) 비율 — 차트 전체의 에너지 방향성 (외향 vs 내향)
2. 4원소 분포 (火/土/空/水) — 지배 원소와 결핍 원소, 그 심리적 의미
3. 퀄리티(Cardinal/Fixed/Mutable) 분포 — 행동 패턴과 변화 적응 방식
4. 에센셜 디그니티 — 지배행성의 강약 (Domicile/Exaltation/Detriment/Fall)
5. 핵심 어스펙트 패턴 — 가장 영향력 있는 각도 1~3개와 그 의미 (달의 각도는 오차가 클 수 있으니 주의해서 언급할 것)
6. 종합 — 이 사람의 핵심 주제 2~3가지 (삶에서 반복될 가능성이 높은 패턴)

*주의사항*: 출생 시간을 모르는 내담자이므로, ASC(Ascendant), MC, 그리고 ℎ(House) 영역에 대한 분석은 절대 포함하지 마세요.
'''
            : '''
[분석 순서]
1. 음양(Yin/Yang) 비율 — 차트 전체의 에너지 방향성 (외향 vs 내향)
2. 4원소 분포 (火/土/空/水) — 지배 원소와 결핍 원소, 그 심리적 의미
3. 퀄리티(Cardinal/Fixed/Mutable) 분포 — 행동 패턴과 변화 적응 방식
4. 에센셜 디그니티 — 지배행성의 강약 (Domicile/Exaltation/Detriment/Fall)
5. 강조된 ℎ — 어느 삶의 영역에 에너지가 집중되어 있는가
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
6. '하우스' 또는 '집'이라는 단어는 절대 사용하지 말고, 대신 기호 'ℎ'로만 표기할 것. (예: 1하우스/1번째 집 -> 1ℎ, 10하우스/10번째 집 -> 10ℎ)
7. 어센던트(Ascendant)는 'ASC', 디센던트(Descendant)는 'DSC', IC는 'IC', MC는 'MC'로 용어를 완전히 통일하여 영문 대문자로만 표기할 것. 절대로 한국어(어센던트, 상승궁, 상승점, 디센던트, 하강궁, 하강점, 남중점, MC, IC 등)로 표기하지 말 것.

[에센셜 디그니티(Essential Dignities) 자가 검증 표]
반드시 아래의 정통 규칙에 맞춰서만 디그니티(Domicile/Exaltation/Detriment/Fall)를 판단하고 설명하세요. 절대 서로 혼동하여 다르게 적지 마십시오:
- Domicile(룰러십): ☉-♌, ☽-♋, ☿-♊/♍, ♀-♉/♎, ♂-♈/♏, ♃-♐/♓, ♄-♑/♒
- Exaltation(엑절테이션): ☉-♈, ☽-♉, ☿-♍, ♀-♓, ♂-♑, ♃-♋, ♄-♎
- Detriment(디트리먼트): ☉-♒, ☽-♑, ☿-♐/♓, ♀-♈/♏, ♂-♉/♎, ♃-♊/♍, ♄-♋/♌
- Fall(폴): ☉-♎, ☽-♏, ☿-♓, ♀-♍, ♂-♋, ♃-♑, ♄-♈

[하우스 디그니티 및 강약 자가 검증 표]
행성이 위치한 ℎ의 성격과 힘(길흉)을 분석할 때 다음의 전통 규칙을 적극 반영하세요:
1. 길한 ℎ (Auspicious): 1ℎ, 10ℎ, 5ℎ, 9ℎ, 11ℎ (여기에 행성이 위치하면 행성의 긍정적 역량이 잘 발휘됨)
2. 흉한 ℎ (Challenging): 6ℎ, 8ℎ, 12ℎ (여기에 위치한 행성은 억압, 지연, 고충을 겪기 쉬움)
3. 행성의 조이 (Joy of the Planets):
   - ☉의 조이: 9ℎ
   - ☽의 조이: 3ℎ
   - ☿의 조이: 1ℎ
   - ♀의 조이: 5ℎ
   - ♂의 조이: 6ℎ
   - ♃의 조이: 11ℎ
   - ♄의 조이: 12ℎ

$analysisSteps

한국어로 작성. 전문 용어는 영어 병기 사용. 분석 분량: 중간 정도(너무 짧지도 길지도 않게).
''';

    final userContent = '''
[Placements (행성 배치)]
${placements.join('\n')}

[Aspects (5° Orb)]
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

    final symbolRule = '''

[추가 필수 규칙]
1. 모든 행성과 사인, 어스펙트는 한글 텍스트 대신 반드시 기호(☉, ☽, ☿, ♀, ♂, ♃, ♄, ♅, ♆, ♇, ♈, ♉, ♊, ♋, ♌, ♍, ♎, ♏, ♐, ♑, ♒, ♓, ☌, ✶, □, △, ☍)로만 표기하여 글 길이를 줄일 것.
2. 4원소를 표기할 때는 반드시 한자(火, 土, 空, 水)를 사용할 것.
3. 결과를 출력할 때 불필요한 서론이나 맺음말을 생략하고, 핵심 내용만 간결하게 요약하여 전달할 것.
4. '하우스' 또는 '집'이라는 단어는 절대 사용하지 말고, 대신 기호 'ℎ'로만 표기할 것. (예: 1하우스/1번째 집 -> 1ℎ, 10하우스/10번째 집 -> 10ℎ)
5. 어센던트(Ascendant)는 'ASC', 디센던트(Descendant)는 'DSC', IC는 'IC', MC는 'MC'로 용어를 완전히 통일하여 영문 대문자로만 표기할 것. 절대로 한국어(어센던트, 상승궁, 상승점, 디센던트, 하강궁, 하강점, 남중점, MC, IC 등)로 표기하지 말 것.
6. 에센셜 디그니티를 언급할 때는 반드시 아래의 정통 규칙에 맞춰서만 판단하고 설명하세요. 절대 서로 혼동하여 다르게 적지 마십시오:
   - Domicile(룰러십): ☉-♌, ☽-♋, ☿-♊/♍, ♀-♉/♎, ♂-♈/♏, ♃-♐/♓, ♄-♑/♒
   - Exaltation(엑절테이션): ☉-♈, ☽-♉, ☿-♍, ♀-♓, ♂-♑, ♃-♋, ♄-♎
   - Detriment(디트리먼트): ☉-♒, ☽-♑, ☿-♐/♓, ♀-♈/♏, ♂-♉/♎, ♃-♊/♍, ♄-♋/♌
   - Fall(폴): ☉-♎, ☽-♏, ☿-♓, ♀-♍, ♂-♋, ♃-♑, ♄-♈
7. 행성이 위치한 ℎ의 성격과 힘(길흉)을 분석할 때 다음의 전통 규칙을 적극 반영하세요:
   - 길한 ℎ (Auspicious): 1ℎ, 10ℎ, 5ℎ, 9ℎ, 11ℎ (행성의 긍정적 역량이 발휘되기 쉬움)
   - 흉한 ℎ (Challenging): 6ℎ, 8ℎ, 12ℎ (행성의 역량 발현이 지연되거나 어려움을 겪기 쉬움)
   - 행성의 조이 (Joy of the Planets): ☉-9ℎ, ☽-3ℎ, ☿-1ℎ, ♀-5ℎ, ♂-6ℎ, ♃-11ℎ, ♄-12ℎ
''';

    final customSystemPrompt = pref.systemPrompt + symbolRule;

    final opinion = await _callApi(
      systemPrompt: customSystemPrompt,
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
    var modelNameSanitized = pref.modelName.trim().toLowerCase().replaceAll(
      ' ',
      '-',
    );


    Uri uri;
    Map<String, String> headers;
    Map<String, dynamic> body;

    if (isGemini) {
      // Gemini Native REST API
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/$modelNameSanitized:generateContent?key=${pref.apiKey}';
      uri = Uri.parse(url);
      headers = {'Content-Type': 'application/json'};
      body = {
        "systemInstruction": {
          "parts": [
            {"text": systemPrompt},
          ],
        },
        "contents": [
          {
            "parts": [
              {"text": userContent},
            ],
          },
        ],
        "generationConfig": {"temperature": 0.7},
      };
    } else {
      // OpenAI Compatible API
      final endpoint =
          pref.customEndpoint.endsWith('/')
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
        String rawText = '';

        if (isGemini) {
          final candidates = json['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>;
            final parts = content['parts'] as List<dynamic>;
            if (parts.isNotEmpty) {
              rawText = parts[0]['text'] as String;
            }
          }
        } else {
          final choices = json['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            rawText = choices[0]['message']['content'] as String;
          }
        }

        if (rawText.isNotEmpty) {
          // Post-process to ensure all variations of house/h/하우스/집 are unified to 'ℎ'
          rawText = rawText.replaceAllMapped(
            RegExp(
              r'(\d+)(?:st|nd|rd|th)?\s*(?:번째\s*집|번째\s*하우스|번\s*하우스|하우스|집|house\b|h\b)',
              caseSensitive: false,
            ),
            (match) => '${match.group(1)}ℎ',
          );
          rawText = rawText.replaceAll('하우스', 'ℎ');
          rawText = rawText.replaceAll(RegExp(r'\bhouse\b', caseSensitive: false), 'ℎ');

          // Standardize astrological symbols from emoji-like characters to standard Unicode symbols (☉, ☽)
          rawText = rawText.replaceAll('☀️', '☉');
          rawText = rawText.replaceAll('🌞', '☉');
          rawText = rawText.replaceAll('🌙', '☽');
          rawText = rawText.replaceAll('🌕', '☽');
          rawText = rawText.replaceAll('🌒', '☽');
          rawText = rawText.replaceAll('🌗', '☽');
          rawText = rawText.replaceAll('🌑', '☽');
          rawText = rawText.replaceAll('🪐', '♄');
          return rawText;
        }
        throw Exception('AI 응답 결과가 비어 있습니다.');
      } else {
        final maskedKey = pref.apiKey.length > 8
            ? '${pref.apiKey.substring(0, 4)}...${pref.apiKey.substring(pref.apiKey.length - 4)}'
            : 'short_or_empty';
        throw Exception(
          'AI 요청 실패 (HTTP ${response.statusCode})\n[Model: $modelNameSanitized]\n[Key: $maskedKey]\n$responseBody',
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  /// 실시간 서울 시간 기준 트랜짓-네이탈 종합 상담 분석
  static Future<AiAnalysisResult> analyzeTransitConsultation({
    required List<String> placements,
    required List<String> aspects,
    required List<String> transitAspects,
    required String complaint,
  }) async {
    final pref = await DatabaseService.isar.preferences.get(0) ?? Preference();

    if (pref.apiKey.isEmpty &&
        !pref.customEndpoint.contains('localhost') &&
        !pref.customEndpoint.contains('127.0.0.1')) {
      throw Exception('API Key가 설정되어 있지 않습니다. 설정 화면에서 API Key를 등록해 주세요.');
    }

    final systemInstruction = '''
당신은 전통 및 현대 점성학을 융합한 전문 심리 점성가이자 치료사입니다.
내담자의 네이탈 차트(기본 그릇)와 **현재 대한민국 서울 시간 기준의 트랜짓 영향(Transit-to-Natal Aspects)**을 종합 분석하여, 내담자가 현재 겪고 있는 구체적인 고민에 대한 해법을 제시하세요.

[분석 및 출력 구조]
1. [현재 우주의 기회와 도전]
- 현재 내담자에게 활성화된 주요 트랜짓 영향들(오차범위 3도 이내의 핵심 Transit-to-Natal Aspect들)을 토대로, 지금 이 시기에 내담자가 직면하고 있는 심리적/환경적 도전을 분석하세요.
- 각 트랜짓 분석 시 행성 및 어스펙트 기호를 명시할 것.

2. [현 고민에 대한 단기적 솔루션]
- 내담자의 현재 고민(Complaint)이 이 트랜짓 에너지와 어떻게 상호작용하는지 설명하고, 당장 일상에서 실천할 수 있는 1~3단계의 단기 돌파구를 제시하세요.

3. [진화적 조언]
- 이 트랜짓 시기를 지혜롭게 건너기 위해 가져야 할 마음가짐을 설명하세요.

[필수 표기 규칙]
1. 모든 행성, 사인, 어스펙트는 한글 텍스트 대신 반드시 기호(☉, ☽, ☿, ♀, ♂, ♃, ♄, ♅, ♆, ♇, ☊, ☋, ⚵, ⚸, ⚶, ⚴, ⨂ ♈, ♉, ♊, ♋, ♌, ♍, ♎, ♏, ♐, ♑, ♒, ♓, ☌, ✶, □, △, ☍)로만 표기하세요.
2. 4원소를 표기할 때는 반드시 한자(火, 土, 空, 水)를 사용하세요.
3. 결과를 출력할 때 불필요한 서론이나 맺음말을 생략하고, 바로 본론으로 시작하여 간결하게 작성하세요.

마지막에는 이 상담과 관련된 임상 키워드(태그)를 컴마로 구분해 주세요.
예: Tags: #직장갈등, #토성_성장통, #화성_행동력
''';

    final userContent = '''
[내담자 네이탈 정보]
- Placements:
${placements.join('\n')}
- Aspects:
${aspects.join('\n')}

[서울 기준 트랜짓 정보 (Transit-to-Natal Aspects)]
${transitAspects.isNotEmpty ? transitAspects.join('\n') : '오차 3도 이내의 활성화된 주요 트랜짓 각도가 없습니다.'}

[내담자 현재 고민 (Complaint)]
$complaint
''';

    final opinion = await _callApi(
      systemPrompt: systemInstruction,
      userContent: userContent,
      pref: pref,
    );

    final tags = extractTags(opinion);
    return AiAnalysisResult(opinion: opinion, recommendedTags: tags);
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

  /// 범용 AI 프롬프트 분석 실행 (관계/궁합 및 네이탈 전용)
  static Future<String> generateAnalysis(
    String prompt, {
    bool isTimeUnknown = false,
  }) async {
    final pref = await DatabaseService.isar.preferences.get(0) ?? Preference();

    if (pref.apiKey.isEmpty &&
        !pref.customEndpoint.contains('localhost') &&
        !pref.customEndpoint.contains('127.0.0.1')) {
      throw Exception('API Key가 설정되어 있지 않습니다. 설정 화면에서 API Key를 등록해 주세요.');
    }

    final String timeConstraintRule =
        isTimeUnknown
            ? '''
[출생 시간 미상 분석 규칙 - 필수]
- 한 명 이상의 내담자가 출생 시간을 모릅니다.
- 따라서 ℎ(하우스 영역) 및 ASC/MC/지배 ℎ 포지션 분석은 완전히 제외하세요.
- 대신 다음 요소에 집중하여 캐릭터와 에너지를 해석하세요:
  1. 사인(Zodiac Sign) 중심 캐릭터 및 심리적/성향적 특성
  2. 행성(Planets) 고유의 본질적 에너지와 에센셜 디그니티 (Domicile/Exaltation/Detriment/Fall)
  3. 행성의 룰러(지배 행성)의 상태와 디그니티 강약
  4. 행성 간 어스펙트(Aspects) 상호작용 및 에너지 교환 (달 어스펙트는 가능성으로 부드럽게 제시)
'''
            : '''
[출생 시간 유효 분석 규칙]
- 하우스(ℎ), 포지션, 룰러십 영역 및 행성 어스펙트, 에센셜 디그니티를 입체적으로 통합하여 분석하세요.
''';

    final systemPrompt = '''
당신은 전통 및 현대 점성학을 깊이 있게 연구한 동양/서양 통합 점성가이자 심리치료사입니다.
제공된 점성학 데이터(시나스트리/컴포짓/네이탈)를 바탕으로 두 사람의 관계, 대화 흥미, 에너지 교환, 성격/캐릭터 특성을 친절하고 통찰력 있게 분석하세요.

$timeConstraintRule

[기호 사용 규칙]
1. 모든 행성과 사인, 어스펙트는 한글 텍스트 대신 반드시 기호(☉, ☽, ☿, ♀, ♂, ♃, ♄, ♅, ♆, ♇, ♈, ♉, ♊, ♋, ♌, ♍, ♎, ♏, ♐, ♑, ♒, ♓, ☌, ✶, □, △, ☍)로 표기할 것.
2. 에센셜 디그니티 규칙(Domicile, Exaltation, Detriment, Fall)을 정통 점성학 규칙에 맞추어 지배 행성의 힘과 캐릭터 상태를 판단하세요.
''';

    return await _callApi(
      systemPrompt: systemPrompt,
      userContent: prompt,
      pref: pref,
    );
  }
}

class AiAnalysisResult {
  final String opinion;
  final List<String> recommendedTags;

  AiAnalysisResult({required this.opinion, required this.recommendedTags});
}
