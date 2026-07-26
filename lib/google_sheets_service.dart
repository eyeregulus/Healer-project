import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets_api;
import 'package:googleapis/drive/v3.dart' as drive_api;
import 'package:http/http.dart' as http; // ignore: depend_on_referenced_packages
import 'package:isar/isar.dart';

import 'database_service.dart';
import 'models/client.dart';
import 'models/consultation.dart';

/// Google Sheets 양방향 동기화 서비스
/// - "Healer DB" 스프레드시트를 자동 생성/탐색
/// - Clients / Consultations 두 시트로 구성
/// - Isar(로컬)와 Sheets(클라우드) 양방향 동기화
class GoogleSheetsService {
  static const _spreadsheetName = 'Healer DB';
  static const _clientsSheet = 'Clients';
  static const _consultSheet = 'Consultations';

  // google_sign_in 7.x: singleton instance
  static final _signIn = GoogleSignIn.instance;

  static String? _spreadsheetId;
  static sheets_api.SheetsApi? _sheets;
  static drive_api.DriveApi? _drive;
  static bool _initialized = false;

  static bool get isSignedIn => _initialized;
  static String? get spreadsheetId => _spreadsheetId;

  static const _clientHeaders = [
    'id', 'name', 'birthDate', 'birthTime', 'birthCountry', 'birthCity',
    'timezoneOffset', 'note', 'placements', 'aspects', 'latitude', 'longitude',
    'aiAnalysisResult', 'clinicalObservation', 'aiMatchLevel', 'clinicalTags', 'needsReview'
  ];
  static const _consultHeaders = [
    'id', 'clientId', 'clientName', 'complaint', 'aiOpinion', 'finalTags', 'createdAt',
    'clinicalObservation', 'aiMatchLevel'
  ];

  // ── 인증 ──────────────────────────────────────────────────────────────────

  static Future<bool> signIn({bool silent = false}) async {
    try {
      // google_sign_in 7.x: initialize → authenticate → authorizeScopes
      await _signIn.initialize(
        serverClientId: '687581728272-4vhltdrceipkd7i835m5qh0g33a31h3g.apps.googleusercontent.com',
      );

      GoogleSignInAccount? account;
      try {
        account = await _signIn.attemptLightweightAuthentication();
      } catch (_) {}

      if (account == null) {
        if (silent) return false;
        account = await _signIn.authenticate();
      }

      // 7.x: authorizationClient.authorizeScopes → accessToken
      final auth = await account.authorizationClient.authorizeScopes([
        sheets_api.SheetsApi.spreadsheetsScope,
        drive_api.DriveApi.driveFileScope,
      ]);

      final client = _AuthClient({
        'Authorization': 'Bearer ${auth.accessToken}',
        'Content-Type': 'application/json',
      });
      _sheets = sheets_api.SheetsApi(client);
      _drive = drive_api.DriveApi(client);
      await _ensureSpreadsheet();
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('Google Sheets signIn error: $e');
      if (silent) return false;
      throw Exception('구글 로그인 에러: $e');
    }
  }

  static Future<void> signOut() async {
    await _signIn.signOut();
    _initialized = false;
    _spreadsheetId = null;
    _sheets = null;
    _drive = null;
  }

  // ── 스프레드시트 초기화 ──────────────────────────────────────────────────

  static Future<void> _ensureSpreadsheet() async {
    final result = await _drive!.files.list(
      q: "name='$_spreadsheetName' and mimeType='application/vnd.google-apps.spreadsheet' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id,name)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      _spreadsheetId = result.files!.first.id;
      
      // 기존 스프레드시트가 있는 경우 시트 목록(탭 목록)을 가져와 검증합니다.
      final ss = await _sheets!.spreadsheets.get(_spreadsheetId!);
      final existingTitles = ss.sheets?.map((s) => s.properties?.title).toList() ?? [];
      
      final List<sheets_api.Request> requests = [];
      if (!existingTitles.contains(_clientsSheet)) {
        requests.add(sheets_api.Request(
          addSheet: sheets_api.AddSheetRequest(
            properties: sheets_api.SheetProperties(title: _clientsSheet),
          ),
        ));
      }
      if (!existingTitles.contains(_consultSheet)) {
        requests.add(sheets_api.Request(
          addSheet: sheets_api.AddSheetRequest(
            properties: sheets_api.SheetProperties(title: _consultSheet),
          ),
        ));
      }
      
      if (requests.isNotEmpty) {
        await _sheets!.spreadsheets.batchUpdate(
          sheets_api.BatchUpdateSpreadsheetRequest(requests: requests),
          _spreadsheetId!,
        );
      }
    } else {
      final ss = await _sheets!.spreadsheets.create(
        sheets_api.Spreadsheet(
          properties: sheets_api.SpreadsheetProperties(title: _spreadsheetName),
          sheets: [
            sheets_api.Sheet(properties: sheets_api.SheetProperties(title: _clientsSheet)),
            sheets_api.Sheet(properties: sheets_api.SheetProperties(title: _consultSheet)),
          ],
        ),
      );
      _spreadsheetId = ss.spreadsheetId;
    }
    // 항상 최신 헤더로 덮어쓰기 (열이 변경되었을 때 대비)
    await _writeRow(_clientsSheet, 1, _clientHeaders);
    await _writeRow(_consultSheet, 1, _consultHeaders);
  }

  // ── 행 조작 헬퍼 ─────────────────────────────────────────────────────────

  static Future<void> _writeRow(String sheet, int rowIndex, List<dynamic> values) async {
    await _sheets!.spreadsheets.values.update(
      sheets_api.ValueRange(values: [values.map((v) => v?.toString() ?? '').toList()]),
      _spreadsheetId!,
      '$sheet!A$rowIndex',
      valueInputOption: 'USER_ENTERED',
    );
  }

  static Future<void> _appendRow(String sheet, List<dynamic> values) async {
    await _sheets!.spreadsheets.values.append(
      sheets_api.ValueRange(values: [values.map((v) => v?.toString() ?? '').toList()]),
      _spreadsheetId!,
      '$sheet!A:A',
      valueInputOption: 'USER_ENTERED',
      insertDataOption: 'INSERT_ROWS',
    );
  }

  static Future<int?> _findRowById(String sheet, int id) async {
    final res = await _sheets!.spreadsheets.values.get(_spreadsheetId!, '$sheet!A:A');
    final vals = res.values;
    if (vals == null) return null;
    for (int i = 1; i < vals.length; i++) {
      if (vals[i].isNotEmpty && vals[i][0].toString() == id.toString()) {
        return i + 1;
      }
    }
    return null;
  }

  static Future<void> _deleteRow(String sheet, int rowIndex) async {
    final ss = await _sheets!.spreadsheets.get(_spreadsheetId!);
    final sheetId = ss.sheets
            ?.firstWhere((s) => s.properties?.title == sheet,
                orElse: () => sheets_api.Sheet())
            .properties
            ?.sheetId ??
        0;

    await _sheets!.spreadsheets.batchUpdate(
      sheets_api.BatchUpdateSpreadsheetRequest(requests: [
        sheets_api.Request(
          deleteDimension: sheets_api.DeleteDimensionRequest(
            range: sheets_api.DimensionRange(
              sheetId: sheetId,
              dimension: 'ROWS',
              startIndex: rowIndex - 1,
              endIndex: rowIndex,
            ),
          ),
        ),
      ]),
      _spreadsheetId!,
    );
  }

  // ── Client CRUD ───────────────────────────────────────────────────────────

  static Future<void> upsertClient(Client client) async {
    if (!_initialized) return;
    try {
      final row = _clientToRow(client);
      final existing = await _findRowById(_clientsSheet, client.id);
      if (existing != null) {
        await _writeRow(_clientsSheet, existing, row);
      } else {
        await _appendRow(_clientsSheet, row);
      }
    } catch (e) {
      debugPrint('Sheets upsertClient error: $e');
    }
  }

  static Future<void> deleteClient(int id) async {
    if (!_initialized) return;
    try {
      final row = await _findRowById(_clientsSheet, id);
      if (row != null) await _deleteRow(_clientsSheet, row);
    } catch (e) {
      debugPrint('Sheets deleteClient error: $e');
    }
  }

  static List<dynamic> _clientToRow(Client c) {
    final parts = c.birthPlace.split('/');
    final country = parts.isNotEmpty ? parts[0] : '';
    final city = parts.length > 1 ? parts[1] : '';

    return [
      c.id, c.name,
      "'${c.birthDate.toIso8601String().substring(0, 10)}",
      "'${c.birthTime}", country, city, c.timezoneOffset,
      c.note,
      c.placements.join(';'),
      c.aspects.join(';'),
      c.latitude,
      c.longitude,
      c.aiAnalysisResult,
      c.clinicalObservation,
      c.aiMatchLevel,
      c.clinicalTags.join(';'),
      c.needsReview ? 'TRUE' : 'FALSE'
    ];
  }

  static Client? _rowToClient(List<dynamic> row) {
    if (row.length < 2) return null;
    try {
      final c = Client()
        ..id = int.parse(row[0].toString())
        ..name = row[1].toString();

      // 날짜 파싱 (구글 시트 고유 일련번호로 변환되었을 경우도 방어)
      if (row.length > 2) {
        String dateStr = row[2].toString().replaceAll("'", "");
        final serialDate = int.tryParse(dateStr);
        if (serialDate != null && serialDate > 30000) {
          c.birthDate = DateTime(1899, 12, 30).add(Duration(days: serialDate));
        } else {
          c.birthDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        }
      } else {
        c.birthDate = DateTime.now();
      }
      
      if (row.length > 3) {
        String timeStr = row[3].toString().replaceAll("'", "");
        final serialTime = double.tryParse(timeStr);
        if (serialTime != null && serialTime < 1.0) {
          final totalMinutes = (serialTime * 24 * 60).round();
          final h = totalMinutes ~/ 60;
          final m = totalMinutes % 60;
          timeStr = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        }
        c.birthTime = timeStr;
      } else {
        c.birthTime = '00:00';
      }

      final country = row.length > 4 ? row[4].toString() : '';
      final city = row.length > 5 ? row[5].toString() : '';
      c.birthPlace = '$country/$city';

      c.timezoneOffset = row.length > 6 ? (double.tryParse(row[6].toString()) ?? 0.0) : 0.0;
      c.note = row.length > 7 ? row[7].toString() : '';
      c.placements = row.length > 8 ? row[8].toString().split(';').where((s) => s.isNotEmpty).toList() : [];
      c.aspects = row.length > 9 ? row[9].toString().split(';').where((s) => s.isNotEmpty).toList() : [];
      c.latitude = row.length > 10 ? (double.tryParse(row[10].toString()) ?? 0.0) : 0.0;
      c.longitude = row.length > 11 ? (double.tryParse(row[11].toString()) ?? 0.0) : 0.0;
      c.aiAnalysisResult = row.length > 12 ? row[12].toString() : '';
      c.clinicalObservation = row.length > 13 ? row[13].toString() : '';
      c.aiMatchLevel = row.length > 14 ? row[14].toString() : '';
      c.clinicalTags = row.length > 15 ? row[15].toString().split(';').where((s) => s.isNotEmpty).toList() : [];
      c.needsReview = row.length > 16 ? row[16].toString().toUpperCase() == 'TRUE' : false;

      return c;
    } catch (_) {
      return null;
    }
  }

  // ── Consultation CRUD ─────────────────────────────────────────────────────

  static Future<void> upsertConsultation(Consultation c) async {
    if (!_initialized) return;
    try {
      final row = _consultToRow(c);
      final existing = await _findRowById(_consultSheet, c.id);
      if (existing != null) {
        await _writeRow(_consultSheet, existing, row);
      } else {
        await _appendRow(_consultSheet, row);
      }
    } catch (e) {
      debugPrint('Sheets upsertConsultation error: $e');
    }
  }

  static Future<void> deleteConsultation(int id) async {
    if (!_initialized) return;
    try {
      final row = await _findRowById(_consultSheet, id);
      if (row != null) await _deleteRow(_consultSheet, row);
    } catch (e) {
      debugPrint('Sheets deleteConsultation error: $e');
    }
  }

  static List<dynamic> _consultToRow(Consultation c) => [
        c.id, c.clientId, c.clientName, c.complaint, c.aiOpinion,
        c.finalTags.join(';'),
        c.createdAt.toIso8601String(),
        c.clinicalObservation,
        c.aiMatchLevel,
      ];

  static Consultation? _rowToConsultation(List<dynamic> row) {
    if (row.length < 3) return null;
    try {
      final c = Consultation()
        ..id = int.parse(row[0].toString())
        ..clientId = int.parse(row[1].toString())
        ..clientName = row[2].toString();
      
      c.complaint = row.length > 3 ? row[3].toString() : '';
      c.aiOpinion = row.length > 4 ? row[4].toString() : '';
      c.finalTags = row.length > 5 ? row[5].toString().split(';').where((s) => s.isNotEmpty).toList() : [];
      c.createdAt = row.length > 6 ? DateTime.parse(row[6].toString()) : DateTime.now();
      c.clinicalObservation = row.length > 7 ? row[7].toString() : '';
      c.aiMatchLevel = row.length > 8 ? row[8].toString() : '';
      return c;
    } catch (_) {
      return null;
    }
  }

  // ── 전체 동기화 ───────────────────────────────────────────────────────────

  /// Sheets → Isar (앱 시작 시 / 수동 pull)
  static Future<void> pullAll() async {
    if (!_initialized) return;
    try {
      final clientData = await _sheets!.spreadsheets.values
          .get(_spreadsheetId!, '$_clientsSheet!A2:Z');
      for (final row in clientData.values ?? []) {
        final client = _rowToClient(row);
        if (client != null) {
          final localClient = await DatabaseService.isar.clients.get(client.id);
          if (localClient != null) {
            client.latitude = localClient.latitude;
            client.longitude = localClient.longitude;
          }
          await DatabaseService.isar
              .writeTxn(() async => DatabaseService.isar.clients.put(client));
        }
      }

      final consultData = await _sheets!.spreadsheets.values
          .get(_spreadsheetId!, '$_consultSheet!A2:Z');
      for (final row in consultData.values ?? []) {
        final c = _rowToConsultation(row);
        if (c != null) {
          await DatabaseService.isar
              .writeTxn(() async => DatabaseService.isar.consultations.put(c));
        }
      }
    } catch (e) {
      debugPrint('Sheets pullAll error: $e');
    }
  }

  /// Isar → Sheets (기존 로컬 데이터 전체 업로드 / 덮어쓰기)
  static Future<void> pushAll() async {
    if (!_initialized) return;
    try {
      // 기존 구글 시트 데이터 초기화 (충돌 방지)
      await _sheets!.spreadsheets.values.clear(
          sheets_api.ClearValuesRequest(), _spreadsheetId!, '$_clientsSheet!A2:Z');
      await _sheets!.spreadsheets.values.clear(
          sheets_api.ClearValuesRequest(), _spreadsheetId!, '$_consultSheet!A2:Z');

      final clients = await DatabaseService.isar.clients.where().findAll();
      final consults = await DatabaseService.isar.consultations.where().findAll();

      // 마이그레이션: 각 내담자의 상담이력 태그들을 내담자의 clinicalTags로 자동 취합 및 병합
      for (final client in clients) {
        final clientConsults = consults.where((c) => c.clientId == client.id);
        final allConsultTags = clientConsults.expand((c) => c.finalTags).toList();
        if (allConsultTags.isNotEmpty) {
          final mergedTags = Set<String>.from(client.clinicalTags)..addAll(allConsultTags);
          if (mergedTags.length > client.clinicalTags.length) {
            client.clinicalTags = mergedTags.toList();
            await DatabaseService.isar.writeTxn(() async {
              await DatabaseService.isar.clients.put(client);
            });
          }
        }
      }

      if (clients.isNotEmpty) {
        await _sheets!.spreadsheets.values.append(
          sheets_api.ValueRange(
            values: clients
                .map((c) =>
                    _clientToRow(c).map((v) => v?.toString() ?? '').toList())
                .toList(),
          ),
          _spreadsheetId!, '$_clientsSheet!A2',
          valueInputOption: 'USER_ENTERED',
          insertDataOption: 'INSERT_ROWS',
        );
      }

      if (consults.isNotEmpty) {
        await _sheets!.spreadsheets.values.append(
          sheets_api.ValueRange(
            values: consults
                .map((c) =>
                    _consultToRow(c).map((v) => v?.toString() ?? '').toList())
                .toList(),
          ),
          _spreadsheetId!, '$_consultSheet!A2',
          valueInputOption: 'USER_ENTERED',
          insertDataOption: 'INSERT_ROWS',
        );
      }
    } catch (e) {
      debugPrint('Sheets pushAll error: $e');
    }
  }
}

/// Bearer 토큰 주입용 HTTP 클라이언트
class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _inner = http.Client();
  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
