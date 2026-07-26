import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';
import 'models/client.dart';
import 'models/consultation.dart';
import 'database_service.dart';

/// Firestore 동기화 레이어
/// - Isar(로컬)가 항상 정본(Source of Truth)
/// - 저장/삭제 시 Firestore에도 동일하게 반영
/// - 앱 시작 시 클라우드 → 로컬 풀 동기화
class FirebaseService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// 현재 로그인된 유저 ID. 익명 로그인 시 자동 부여되는 uid 사용.
  static String? get _uid => _auth.currentUser?.uid;

  /// 익명 로그인 (계정 없이 유저별 데이터 분리)
  static Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // ─── Collection References ───────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> get _clientsRef =>
      _db.collection('users').doc(_uid).collection('clients');

  static CollectionReference<Map<String, dynamic>> get _consultationsRef =>
      _db.collection('users').doc(_uid).collection('consultations');

  // ─── Client Sync ─────────────────────────────────────────────────────────

  /// 내담자 저장 (신규 + 수정 모두)
  static Future<void> upsertClient(Client client) async {
    if (_uid == null) return;
    try {
      await _clientsRef.doc('${client.id}').set(client.toJson());
    } catch (_) {
      // 오프라인 시 Firestore가 로컬 캐시에 보관 → 온라인 복귀 시 자동 반영
    }
  }

  /// 내담자 삭제
  static Future<void> deleteClient(int clientId) async {
    if (_uid == null) return;
    try {
      await _clientsRef.doc('$clientId').delete();
    } catch (_) {}
  }

  // ─── Consultation Sync ────────────────────────────────────────────────────

  /// 상담 기록 저장 (신규 + 수정 모두)
  static Future<void> upsertConsultation(Consultation c) async {
    if (_uid == null) return;
    try {
      await _consultationsRef.doc('${c.id}').set(c.toJson());
    } catch (_) {}
  }

  /// 상담 기록 삭제
  static Future<void> deleteConsultation(int consultationId) async {
    if (_uid == null) return;
    try {
      await _consultationsRef.doc('$consultationId').delete();
    } catch (_) {}
  }

  // ─── Full Sync (클라우드 → 로컬) ─────────────────────────────────────────

  /// 앱 시작 시 1회 호출: Firestore 데이터를 Isar에 병합
  /// - 클라우드에 있고 로컬에 없는 것: 로컬에 추가
  /// - 로컬에 있고 클라우드에 없는 것: 건드리지 않음 (로컬 우선)
  static Future<void> pullFromCloud() async {
    if (_uid == null) return;

    try {
      // Pull clients
      final clientSnap = await _clientsRef.get();
      for (final doc in clientSnap.docs) {
        final client = Client.fromJson(doc.data());
        final existing = await DatabaseService.isar.clients.get(client.id);
        if (existing == null) {
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.clients.put(client);
          });
        }
      }

      // Pull consultations
      final consultSnap = await _consultationsRef.get();
      for (final doc in consultSnap.docs) {
        final consult = Consultation.fromJson(doc.data());
        final existing = await DatabaseService.isar.consultations.get(consult.id);
        if (existing == null) {
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.consultations.put(consult);
          });
        }
      }
    } catch (_) {
      // 오프라인이면 그냥 로컬 데이터로 동작
    }
  }

  // ─── Local → Cloud 전체 업로드 (최초 1회 마이그레이션용) ─────────────────

  /// 기존 로컬 데이터를 클라우드에 한 번에 올릴 때 사용
  static Future<void> pushAllToCloud() async {
    if (_uid == null) return;

    final clientList = await DatabaseService.isar.clients.where().findAll();
    for (final client in clientList) {
      await upsertClient(client);
    }

    final consultationList = await DatabaseService.isar.consultations.where().findAll();
    for (final c in consultationList) {
      await upsertConsultation(c);
    }
  }
}
