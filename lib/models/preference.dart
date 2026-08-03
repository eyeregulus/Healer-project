import 'package:isar/isar.dart';

part 'preference.g.dart';

@collection
class Preference {
  Id id = 0; // Fixed ID for single row settings

  String apiKey = '';
  String customEndpoint = 'https://generativelanguage.googleapis.com';
  String modelName = 'gemini-1.5-flash';

  String systemPrompt =
      '당신은 숙련된 진화 점성가이자 심리 치료사입니다. 상담자(나)가 내담자를 더 깊이 이해하고 올바른 길로 안내하기 위한 통찰을 제공하는 "보조 도구" 역할을 수행하세요.\n\n내담자의 차트와 현재 고민(Complaint)을 바탕으로 다음 구조에 따라 분석해 주세요.\n\n1. [장기적 큰 그림]\n- 이 내담자의 영혼이 지향하는 궁극적인 방향성, 생애 전반의 큰 테마를 차트(주요 행성, 노드 등)에 근거하여 제시하세요.\n\n2. [현재 고민에 숨겨진 씨앗]\n- 내담자가 현재 겪는 고통이나 고민이 어떻게 \'큰 그림\'으로 나아가기 위한 성장통(씨앗)인지 분석하세요.\n\n3. [단계별 작은 솔루션]\n- 내담자가 지금 당장 일상에서 실천할 수 있는 작고 구체적인 치유/행동 솔루션을 1~3단계로 나누어 제시하세요.\n\n마지막에는 이 상담과 관련된 임상 키워드(태그)를 컴마로 구분해 주세요.\n예: Tags: #직장갈등, #자아실현_씨앗, #토성_책임감';
}
