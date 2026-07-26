import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'add_consultation_screen.dart';
import 'transit_consultation_screen.dart';
import 'ai_service.dart';
import 'astrology_service.dart';
import 'database_service.dart';
import 'edit_client_screen.dart';
import 'google_sheets_service.dart';
import 'models/client.dart';
import 'models/consultation.dart';
import 'app_snackbar.dart';
import 'themes.dart';
import 'widgets/natal_chart_wheel.dart';

class ClientDetailsScreen extends StatefulWidget {
  final int clientId;

  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Client? _client;
  List<Consultation> _consultations = [];
  bool _isLoading = true;

  // AI 기초 분석 상태
  String? _aiAnalysisResult;
  bool _isAnalyzing = false;
  String? _aiAnalysisError;

  // Phase 2: 임상 관찰 노트 상태
  final _observationController = TextEditingController();
  String _aiMatchLevel = ''; // 'match' | 'partial' | 'mismatch' | ''
  List<String> _clinicalTags = [];
  bool _needsReview = false;
  bool _isHeaderExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClientData();
    _loadClinicalState();
  }

  Future<void> _loadClientData() async {
    try {
      final client = await DatabaseService.isar.clients.get(widget.clientId);
      if (client != null) {
        setState(() {
          _client = client;
        });
        _loadClinicalState();
        final consultations =
            await DatabaseService.isar.consultations
                .filter()
                .clientIdEqualTo(widget.clientId)
                .sortByCreatedAtDesc()
                .findAll();

        setState(() {
          _consultations = consultations;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadClinicalState() {
    final c = _client;
    if (c == null) return;
    _observationController.text = c.clinicalObservation;
    _aiMatchLevel = c.aiMatchLevel;
    _clinicalTags = List<String>.from(c.clinicalTags);
    _needsReview = c.needsReview;
    if (c.aiAnalysisResult.isNotEmpty) {
      _aiAnalysisResult = c.aiAnalysisResult;
    }
  }

  Future<void> _saveClinicalNote() async {
    if (_client == null) return;
    try {
      await DatabaseService.isar.writeTxn(() async {
        final fresh = await DatabaseService.isar.clients.get(_client!.id);
        if (fresh != null) {
          fresh
            ..clinicalObservation = _observationController.text
            ..aiMatchLevel = _aiMatchLevel
            ..clinicalTags = _clinicalTags
            ..needsReview = _needsReview;
          await DatabaseService.isar.clients.put(fresh);
          _client = fresh;
        }
      });
      // 구글 시트에 즉시 업데이트 (트랜잭션 외부에서 실행)
      if (_client != null) {
        GoogleSheetsService.upsertClient(_client!);
      }
      if (mounted) {
        AppSnackBar.show(context, message: '임상 관찰 노트가 저장되었습니다.');
      }
    } catch (e) {
      if (mounted) AppSnackBar.show(context, message: '저장 실패: $e');
    }
  }

  Future<void> _runAiAnalysis() async {
    if (_client == null) return;
    setState(() {
      _isAnalyzing = true;
      _aiAnalysisError = null;
    });

    try {
      final isUnknown = _client!.birthTime == 'Unknown';
      List<String> filteredPlacements = _client!.placements;

      if (isUnknown) {
        filteredPlacements =
            _client!.placements.where((p) {
              final pLower = p.toLowerCase();
              return !pLower.contains('house') &&
                  !pLower.contains('ascendant') &&
                  !pLower.contains('mc');
            }).toList();
      }

      final result = await AiService.analyzeNatalChart(
        placements: filteredPlacements,
        aspects: _client!.aspects,
        isTimeUnknown: isUnknown,
      );

      // Save to Database
      await DatabaseService.isar.writeTxn(() async {
        final fresh = await DatabaseService.isar.clients.get(_client!.id);
        if (fresh != null) {
          fresh.aiAnalysisResult = result;
          await DatabaseService.isar.clients.put(fresh);
          _client = fresh;
        }
      });

      // 구글 시트에 즉시 업데이트 (트랜잭션 외부에서 실행)
      if (_client != null) {
        GoogleSheetsService.upsertClient(_client!);
      }

      setState(() {
        _aiAnalysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _aiAnalysisError = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  String _formatTimezone(String birthPlace, double offset) {
    final placeLower = birthPlace.toLowerCase();
    if (offset == 9.0) {
      if (placeLower.contains('tokyo') ||
          placeLower.contains('japan') ||
          placeLower.contains('도쿄') ||
          placeLower.contains('일본')) {
        return 'JST-9';
      }
      return 'KST-9';
    }
    if (offset == 0.0) return 'UTC';
    final sign = offset > 0 ? '+' : '-';
    final absVal = offset.abs().toStringAsFixed(1).replaceAll('.0', '');
    return 'UTC$sign$absVal';
  }

  Future<void> _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('내담자 삭제'),
            content: Text(
              '정말로 ${_client?.name} 내담자의 모든 정보와 상담 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final List<int> consultIdsToDelete = [];
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.clients.delete(widget.clientId);
        final consultationsToDelete =
            await DatabaseService.isar.consultations
                .filter()
                .clientIdEqualTo(widget.clientId)
                .findAll();
        for (final consultation in consultationsToDelete) {
          await DatabaseService.isar.consultations.delete(consultation.id);
          consultIdsToDelete.add(consultation.id);
        }
      });

      // 구글 시트 삭제는 트랜잭션 외부에서 수행
      GoogleSheetsService.deleteClient(widget.clientId);
      for (final id in consultIdsToDelete) {
        GoogleSheetsService.deleteConsultation(id);
      }

      if (mounted) {
        AppSnackBar.show(context, message: '삭제되었습니다.');
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Themes.gold)),
      );
    }

    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('상세 정보')),
        body: const Center(child: Text('해당 내담자를 찾을 수 없습니다.')),
      );
    }

    final dateStr =
        '${_client!.birthDate.year}년 ${_client!.birthDate.month}월 ${_client!.birthDate.day}일';

    return Scaffold(
      appBar: AppBar(
        title: Text('${_client!.name} 님의 차트'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Themes.gold),
            tooltip: '프로필 수정',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditClientScreen(client: _client!),
                ),
              );
              if (result == true) _loadClientData();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(dateStr),
          TabBar(
            controller: _tabController,
            indicatorColor: Themes.gold,
            labelColor: Themes.gold,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: '네이탈 차트'),
              Tab(text: 'AI 기초 분석'),
              Tab(text: '상담 이력'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartTab(),
                _buildAiAnalysisTab(),
                _buildConsultationsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showConsultationOptions,
        backgroundColor: Themes.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('상담 작성'),
      ),
    );
  }

  void _showConsultationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  '상담 방식 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Themes.gold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.history_edu_rounded,
                    color: Themes.gold,
                  ),
                  title: const Text('일반 상담 작성 (네이탈 기반)'),
                  subtitle: const Text(
                    '출생 차트 배치를 기반으로 심리적/진화적 기저를 분석하고 상담을 작성합니다.',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddConsultationScreen(
                              clientId: _client!.id,
                              clientName: _client!.name,
                              placements: _client!.placements,
                              aspects: _client!.aspects,
                            ),
                      ),
                    );
                    if (result == true) _loadClientData();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Themes.gold,
                  ),
                  title: const Text('실시간 트랜짓 AI 상담 (신규)'),
                  subtitle: const Text(
                    '현재 대한민국 서울 상공의 트랜짓 행성과 출생 차트를 실시간 비교 분석합니다.',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                TransitConsultationScreen(client: _client!),
                      ),
                    );
                    if (result == true) _loadClientData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Tab 1: 네이탈 차트 ───────────────────────────────────────────────────

  Widget _buildChartTab() {
    final planetPlacements = <String>[];
    final housePlacements = <String>[];

    for (final p in _client!.placements) {
      if (p.contains('House')) {
        housePlacements.add(AstrologyService.translatePlacement(p));
      } else {
        planetPlacements.add(AstrologyService.translatePlacement(p));
      }
    }

    final aspectsTranslated =
        _client!.aspects
            .map((a) => AstrologyService.translateAspect(a))
            .toList();

    final natalData = AstrologyService.calculateNatalData(
      birthDate: _client!.birthDate,
      birthTime: _client!.birthTime,
      latitude: _client!.latitude,
      longitude: _client!.longitude,
      timezoneOffset: _client!.timezoneOffset,
    );
    final longitudes = natalData['longitudes'] as Map<String, double>;
    final cusps = natalData['cusps'] as List<double>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Natal Chart Wheel
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                NatalChartWheel(
                  longitudes: longitudes,
                  cusps: cusps,
                  aspects: _client!.aspects,
                ),
                const SizedBox(height: 12),
                Text(
                  '${_client!.name}님의 네이탈 차트 (탄생 천궁도)',
                  style: const TextStyle(
                    color: Themes.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildChartProfilePanel(longitudes),
          const SizedBox(height: 24),

          // Progressed Lunar Phase Card
          () {
            final progressedData =
                AstrologyService.calculateProgressedLunarPhase(
                  birthDate: _client!.birthDate,
                  birthTime: _client!.birthTime,
                  timezoneOffset: _client!.timezoneOffset,
                );
            return _buildProgressedLunarCard(progressedData);
          }(),
          const SizedBox(height: 24),

          _buildSectionHeader('행성 위치 및 사인', Icons.wb_sunny_rounded),
          const SizedBox(height: 8),
          _buildChipsWrap(planetPlacements),
          const SizedBox(height: 20),

          _buildSectionHeader('하우스 배치', Icons.home_rounded),
          const SizedBox(height: 8),
          _buildChipsWrap(housePlacements),
          const SizedBox(height: 20),

          _buildSectionHeader('격각', Icons.hub_rounded),
          const SizedBox(height: 8),
          if (aspectsTranslated.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '감지된 주요 각도가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  aspectsTranslated.map((a) {
                    final isTense = a.contains('□') || a.contains('☍');
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isTense
                                ? Colors.redAccent.withValues(alpha: 0.08)
                                : Themes.gold.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isTense
                                  ? Colors.redAccent.withValues(alpha: 0.35)
                                  : Themes.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        a,
                        style: TextStyle(
                          fontSize: 15,
                          color: isTense ? Colors.redAccent : Themes.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildProgressedLunarCard(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final age = data['age'] as double;
    final phaseName = data['phaseName'] as String;
    final seasonName = data['seasonName'] as String;
    final description = data['description'] as String;
    final icon = data['icon'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Themes.gold.withValues(alpha: 0.2),
          width: 1.0,
        ),
        boxShadow: [Themes.cardShadow(isDark)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Moon Phase Icon
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        color: Themes.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '나이: 만 ${age.toStringAsFixed(1)}세',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$phaseName — $seasonName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 차트 프로필 패널 (음양 / 화토공수 / 퀄리티) ───────────────────────────

  Widget _buildChartProfilePanel(Map<String, double> longitudes) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = AstrologyService.analyzeChartProfile(longitudes);

    final int fire = profile['fire'] as int;
    final int earth = profile['earth'] as int;
    final int air = profile['air'] as int;
    final int water = profile['water'] as int;
    final int yin = profile['yin'] as int;
    final int yang = profile['yang'] as int;
    final int cardinal = profile['cardinal'] as int;
    final int fixed = profile['fixed'] as int;
    final int mutable_ = profile['mutable'] as int;
    final List<String> dominantElements = List<String>.from(
      profile['dominantElements'] as List,
    );
    final String dominantQ = profile['dominantQuality'] as String;
    final List<String> repSigns = List<String>.from(
      profile['repSigns'] as List,
    );

    final elementColor = {
      '화': Colors.redAccent,
      '토': Colors.brown.shade400,
      '공': Colors.lightBlue.shade300,
      '수': Colors.indigo.shade300,
    };

    Widget counter(String label, int count, Color color) => Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.withValues(alpha: 0.8),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Themes.gold.withValues(alpha: 0.2)),
        boxShadow: [Themes.cardShadow(isDark)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Themes.gold,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                '차트 프로필',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Themes.gold,
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // 음양
          Row(
            children: [
              const Text(
                '음양',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Text(
                '음 $yin',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '양 $yang',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orangeAccent,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: yang / 11.0,
                    backgroundColor: Colors.blueGrey.withValues(alpha: 0.3),
                    color: Colors.orangeAccent,
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 화토공수
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              counter('화🔥', fire, elementColor['화']!),
              counter('토🌍', earth, elementColor['토']!),
              counter('공💨', air, elementColor['공']!),
              counter('수💧', water, elementColor['수']!),
            ],
          ),
          const SizedBox(height: 12),

          // 퀄리티
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              counter('카디날', cardinal, Colors.purple.shade300),
              counter('픽스드', fixed, Colors.amber.shade600),
              counter('뮤터블', mutable_, Colors.teal.shade300),
            ],
          ),
          const Divider(height: 16),

          // 대표 캐릭터 = 지배원소 × 지배퀄리티
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_pin_rounded,
                color: Themes.gold,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '지배 원소: ${dominantElements.join(' · ')}  ·  지배 퀄리티: $dominantQ',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children:
                          repSigns
                              .map(
                                (s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Themes.gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Themes.gold.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Themes.gold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: AI 기초 분석 ──────────────────────────────────────────────────

  Widget _buildAiAnalysisTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 안내 헤더
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Themes.gold.withValues(alpha: 0.08)
                      : Themes.gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Themes.gold.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Themes.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI 기초 분석 기준',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Themes.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '음양 비율 · 4원소 분포 · 퀄리티 · 에센셜 디그니티 · 강조 하우스 · 핵심 어스펙트 패턴 · 노드적 해석 적용할것\n\n'
                  '⚠ AI 분석은 참고용 앵커입니다. 분석을 보고 난 후 실제 관찰과 비교하세요.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 분석 생성 버튼
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _runAiAnalysis,
            icon:
                _isAnalyzing
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                    : const Icon(Icons.psychology_rounded),
            label: Text(
              _isAnalyzing
                  ? 'AI 분석 중... (30초~1분 소요)'
                  : _aiAnalysisResult != null
                  ? '다시 분석하기'
                  : 'AI 기초 분석 시작',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Themes.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 결과 또는 에러
          if (_aiAnalysisError != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiAnalysisError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_aiAnalysisResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [Themes.cardShadow(isDark)],
              ),
              child: SelectableText(
                _aiAnalysisResult!,
                style: const TextStyle(fontSize: 14, height: 1.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '* 분석 결과는 저장되지 않습니다. 필요하면 복사해서 상담 메모에 붙여넣으세요.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ─── Tab 3: 상담 이력 ─────────────────────────────────────────────────────

  Widget _buildConsultationsTab() {
    if (_consultations.isEmpty) {
      return const Center(
        child: Text(
          '등록된 상담 기록이 없습니다.\n우측 하단의 상담 작성 버튼을 눌러 상담을 기록하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        final consultation = _consultations[index];
        final createdStr =
            '${consultation.createdAt.year}년 ${consultation.createdAt.month}월 ${consultation.createdAt.day}일';

        final isTransit = consultation.aiOpinion.startsWith('[실시간 트랜짓') ||
            consultation.aiOpinion.startsWith('[T');

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              Themes.cardShadow(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isTransit
                          ? Colors.purple.withValues(alpha: 0.15)
                          : Themes.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isTransit ? Colors.purple : Themes.gold,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isTransit ? 'T' : 'N',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isTransit ? Colors.purpleAccent : Themes.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    createdStr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Themes.gold,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                consultation.complaint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 10),
                      const SizedBox(height: 8),
                      const Text(
                        '내담자 고민',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Themes.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        consultation.complaint,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AI 임상 분석 (원인 3가지)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Themes.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        consultation.aiOpinion,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      if (consultation.aiMatchLevel.isNotEmpty ||
                          consultation.clinicalObservation.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text(
                              '임상 관찰 및 피드백',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Themes.gold,
                              ),
                            ),
                            if (consultation.aiMatchLevel.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      consultation.aiMatchLevel == 'match'
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : consultation.aiMatchLevel ==
                                              'partial'
                                          ? Colors.amber.withValues(alpha: 0.15)
                                          : Colors.redAccent.withValues(
                                            alpha: 0.15,
                                          ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        consultation.aiMatchLevel == 'match'
                                            ? Colors.green
                                            : consultation.aiMatchLevel ==
                                                'partial'
                                            ? Colors.amber
                                            : Colors.redAccent,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  consultation.aiMatchLevel == 'match'
                                      ? '일치'
                                      : consultation.aiMatchLevel == 'partial'
                                      ? '부분 일치'
                                      : '불일치',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        consultation.aiMatchLevel == 'match'
                                            ? Colors.green
                                            : consultation.aiMatchLevel ==
                                                'partial'
                                            ? Colors.amber
                                            : Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (consultation.clinicalObservation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            consultation.clinicalObservation,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        '임상 분석 태그',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Themes.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            consultation.finalTags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                  ),
                                ),
                                backgroundColor: Themes.gold,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── 공통 위젯 ────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(String dateStr) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [Themes.cardShadow(isDark)],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Themes.cardGradient(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing basic details and toggle
          InkWell(
            onTap: () {
              setState(() {
                _isHeaderExpanded = !_isHeaderExpanded;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Themes.gold,
                  child: Icon(Icons.person, color: Colors.black, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _client!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Themes.gold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_client!.birthDate.year}.${_client!.birthDate.month}.${_client!.birthDate.day} (${_client!.birthTime})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (!_isHeaderExpanded) ...[
                        const SizedBox(height: 2),
                        Text(
                          '출생지: ${_client!.birthPlace} (${_formatTimezone(_client!.birthPlace, _client!.timezoneOffset)})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  _isHeaderExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Themes.gold,
                  size: 20,
                ),
              ],
            ),
          ),

          if (_isHeaderExpanded) ...[
            const Divider(height: 16, color: Colors.grey),
            // Review Chip
            Row(
              children: [
                const Text(
                  '상태: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _needsReview = !_needsReview;
                    });
                    _saveClinicalNote();
                  },
                  child: Chip(
                    avatar: Icon(
                      _needsReview
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 14,
                      color: _needsReview ? Colors.black : Colors.grey,
                    ),
                    label: Text(
                      '검토 필요',
                      style: TextStyle(
                        fontSize: 10,
                        color: _needsReview ? Colors.black : Colors.grey,
                        fontWeight:
                            _needsReview ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor:
                        _needsReview ? Themes.gold : Colors.transparent,
                    side: BorderSide(
                      color:
                          _needsReview
                              ? Themes.gold
                              : Colors.grey.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Themes.gold,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '출생지: ${_client!.birthPlace} (${_formatTimezone(_client!.birthPlace, _client!.timezoneOffset)})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            if (_client!.note.isNotEmpty) ...[
              const Divider(height: 16, color: Colors.grey),
              const Text(
                '메모',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Themes.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_client!.note, style: const TextStyle(fontSize: 13)),
            ],
            if (_clinicalTags.isNotEmpty) ...[
              const Divider(height: 16, color: Colors.grey),
              const Text(
                '임상 패턴 태그 (검색용)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Themes.gold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    _clinicalTags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                          ),
                        ),
                        backgroundColor: Themes.gold,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.black54,
                        ),
                        onDeleted: () {
                          setState(() {
                            _clinicalTags.remove(tag);
                          });
                          _saveClinicalNote();
                        },
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Themes.gold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Themes.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildChipsWrap(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  Themes.cardShadow(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ],
              ),
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
    );
  }
}
