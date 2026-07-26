import 'package:isar/isar.dart';

part 'preference.g.dart';

@collection
class Preference {
  Id id = 0; // Fixed ID for single row settings

  String apiKey = '';
  String customEndpoint = 'https://api.openai.com/v1';
  String modelName = 'gpt-4o';
  
  String systemPrompt = '당신은 숙련된 임상 점성가이자 심리 치료사입니다. 내담자의 차트 데이터(Placements, Aspects)와 현재 겪고 있는 고민(Complaint)을 바탕으로, 이 고민의 점성학적/심리적 원인 3가지를 명확히 분석해 주세요. 각 원인은 내담자의 차트 특성(예: 특정 행성의 하우스 배치, 흉각 등)과 연결지어 설명해야 합니다.\n\n출력 형식:\n1. [원인 제목]\n- 원인에 대한 점성학적 설명 및 내담자의 심리적 역학 분석\n\n2. [원인 제목]\n- ...\n\n3. [원인 제목]\n- ...\n\n마지막에는 이 고민과 관련이 깊은 임상 키워드(태그)들을 컴마로 구분하여 작성해 주세요.\n예: Tags: #결정장애, #완벽주의, #우울감';
}
