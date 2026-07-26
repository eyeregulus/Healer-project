import 'package:isar/isar.dart';

part 'consultation.g.dart';

@collection
class Consultation {
  Id id = Isar.autoIncrement;

  @Index()
  late int clientId;
  
  late String clientName;
  
  late String complaint;
  late String aiOpinion; // 객관적 원인 3가지
  
  @Index(type: IndexType.hashElements)
  late List<String> finalTags; // ex: ["#결정장애", "#미루기"]
  
  late DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientId': clientId,
    'clientName': clientName,
    'complaint': complaint,
    'aiOpinion': aiOpinion,
    'finalTags': finalTags,
    'createdAt': createdAt.toIso8601String(),
  };

  static Consultation fromJson(Map<String, dynamic> json) {
    final c = Consultation()
      ..id = (json['id'] as num).toInt()
      ..clientId = (json['clientId'] as num).toInt()
      ..clientName = json['clientName'] as String
      ..complaint = json['complaint'] as String
      ..aiOpinion = json['aiOpinion'] as String
      ..finalTags = List<String>.from(json['finalTags'] as List)
      ..createdAt = DateTime.parse(json['createdAt'] as String);
    return c;
  }
}
