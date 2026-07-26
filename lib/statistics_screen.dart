import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'astrology_service.dart';
import 'client_details_screen.dart';
import 'database_service.dart';
import 'models/client.dart';
import 'models/consultation.dart';
import 'themes.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _modeController;

  // ── 모드 1: 상담 태그 통계 (기존) ──────────────────────────────────────
  final _consultSearchController = TextEditingController();
  List<String> _allConsultTags = [];
  List<String> _filteredConsultTags = [];
  String? _selectedConsultTag;
  int _consultTotal = 0;
  List<StatItem> _placementStats = [];
  List<StatItem> _aspectStats = [];

  // ── 모드 2: 임상 관찰 태그 패턴 검색 (Phase 3) ──────────────────────
  final _clinicalSearchController = TextEditingController();
  List<String> _allClinicalTags = [];
  List<String> _filteredClinicalTags = [];
  String? _selectedClinicalTag;
  List<_ClientPatternResult> _patternResults = [];

  // ── 모드 3: 어스펙트/배치 역방향 검색 (Phase 4) ──────────────────────
  final _aspectSearchController = TextEditingController();
  List<String> _allAspects = [];      // raw keys e.g. 'Moon-Saturn-Square'
  List<String> _allAspectLabels = []; // translated display
  List<int> _filteredAspectIndices = [];
  String? _selectedAspect;            // raw key
  List<_ClientPatternResult> _aspectResults = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _modeController = TabController(length: 3, vsync: this);
    _loadAllTags();
  }

  Future<void> _loadAllTags() async {
    setState(() => _isLoading = true);
    try {
      // 상담 태그
      final consultations =
          await DatabaseService.isar.consultations.where().findAll();
      final consultTags = <String>{};
      for (final c in consultations) {
        consultTags.addAll(c.finalTags);
      }
      final consultTagList = consultTags.toList()..sort();

      // 임상 관찰 태그 + 어스펙트 목록
      final clients = await DatabaseService.isar.clients.where().findAll();
      final clinicalTags = <String>{};
      final aspectSet = <String>{};
      for (final c in clients) {
        clinicalTags.addAll(c.clinicalTags);
        aspectSet.addAll(c.aspects);
      }
      final clinicalTagList = clinicalTags.toList()..sort();
      final aspectList = aspectSet.toList()..sort();
      final aspectLabelList = aspectList
          .map((a) => AstrologyService.translateAspect(a))
          .toList();

      setState(() {
        _allConsultTags = consultTagList;
        _filteredConsultTags = consultTagList;
        _allClinicalTags = clinicalTagList;
        _filteredClinicalTags = clinicalTagList;
        _allAspects = aspectList;
        _allAspectLabels = aspectLabelList;
        _filteredAspectIndices = List.generate(aspectList.length, (i) => i);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── 어스펙트 역방향 검색 ──────────────────────────────────────────────

  void _filterAspects(String query) {
    final clean = query.trim().toLowerCase();
    setState(() {
      _filteredAspectIndices = clean.isEmpty
          ? List.generate(_allAspects.length, (i) => i)
          : List.generate(_allAspects.length, (i) => i)
              .where((i) => _allAspectLabels[i].toLowerCase().contains(clean))
              .toList();
    });
  }

  Future<void> _searchByAspect(String rawKey) async {
    setState(() {
      _selectedAspect = rawKey;
      _isLoading = true;
      _aspectResults = [];
    });
    try {
      final allClients = await DatabaseService.isar.clients.where().findAll();
      final matching = allClients.where((c) => c.aspects.contains(rawKey)).toList();
      setState(() {
        _aspectResults = matching.map((c) => _ClientPatternResult(
          client: c,
          observation: c.clinicalObservation,
          aiMatchLevel: c.aiMatchLevel,
          needsReview: c.needsReview,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── 상담 태그 통계 ─────────────────────────────────────────────────────

  void _filterConsultTags(String query) {
    final clean = query.trim().toLowerCase();
    setState(() {
      _filteredConsultTags = clean.isEmpty
          ? _allConsultTags
          : _allConsultTags
              .where((tag) => tag.toLowerCase().contains(clean))
              .toList();
    });
  }

  Future<void> _calculateConsultStats(String tag) async {
    setState(() {
      _selectedConsultTag = tag;
      _isLoading = true;
    });
    try {
      final consultations = await DatabaseService.isar.consultations
          .filter()
          .finalTagsElementEqualTo(tag)
          .findAll();
      final clientIds = consultations.map((c) => c.clientId).toSet();

      if (clientIds.isEmpty) {
        setState(() {
          _consultTotal = 0;
          _placementStats = [];
          _aspectStats = [];
          _isLoading = false;
        });
        return;
      }

      final allClients = await DatabaseService.isar.clients.where().findAll();
      final matching = allClients.where((c) => clientIds.contains(c.id)).toList();
      final total = matching.length;

      final placementCounts = <String, int>{};
      final aspectCounts = <String, int>{};
      for (final client in matching) {
        for (final p in client.placements) {
          placementCounts[p] = (placementCounts[p] ?? 0) + 1;
        }
        for (final a in client.aspects) {
          aspectCounts[a] = (aspectCounts[a] ?? 0) + 1;
        }
      }

      final placementStats = placementCounts.entries
          .map((e) => StatItem(
                label: AstrologyService.translatePlacement(e.key),
                count: e.value,
                percentage: (e.value / total) * 100,
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      final aspectStats = aspectCounts.entries
          .map((e) => StatItem(
                label: AstrologyService.translateAspect(e.key),
                count: e.value,
                percentage: (e.value / total) * 100,
                isTense: e.key.contains('Square') || e.key.contains('Opposition'),
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      setState(() {
        _consultTotal = total;
        _placementStats = placementStats.take(25).toList();
        _aspectStats = aspectStats.take(25).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── 임상 관찰 태그 패턴 검색 ─────────────────────────────────────────

  void _filterClinicalTags(String query) {
    final clean = query.trim().toLowerCase();
    setState(() {
      _filteredClinicalTags = clean.isEmpty
          ? _allClinicalTags
          : _allClinicalTags
              .where((tag) => tag.toLowerCase().contains(clean))
              .toList();
    });
  }

  Future<void> _searchByClinicaltag(String tag) async {
    setState(() {
      _selectedClinicalTag = tag;
      _isLoading = true;
      _patternResults = [];
    });
    try {
      final allClients = await DatabaseService.isar.clients.where().findAll();
      final matching =
          allClients.where((c) => c.clinicalTags.contains(tag)).toList();

      // 공통 어스펙트/배치 집계
      final aspectCounts = <String, int>{};
      for (final c in matching) {
        for (final a in c.aspects) {
          aspectCounts[a] = (aspectCounts[a] ?? 0) + 1;
        }
      }
      final sortedAspects = aspectCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final results = matching.map((c) {
        return _ClientPatternResult(
          client: c,
          observation: c.clinicalObservation,
          aiMatchLevel: c.aiMatchLevel,
          needsReview: c.needsReview,
        );
      }).toList();

      setState(() {
        _patternResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _modeController.dispose();
    _consultSearchController.dispose();
    _clinicalSearchController.dispose();
    _aspectSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('패턴 분석'),
        centerTitle: true,
        bottom: TabBar(
          controller: _modeController,
          indicatorColor: Themes.gold,
          labelColor: Themes.gold,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded), text: '상담 태그'),
            Tab(icon: Icon(Icons.manage_search_rounded), text: '임상 태그'),
            Tab(icon: Icon(Icons.hub_rounded), text: '어스펙트 역검색'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Themes.gold))
          : TabBarView(
              controller: _modeController,
              children: [
                _buildConsultStatsMode(),
                _buildClinicalPatternMode(),
                _buildAspectSearchMode(),
              ],
            ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 모드 3: 어스펙트 역방향 검색 (Phase 4)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAspectSearchMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAspectSearchHeader(),
        Expanded(
          child: _selectedAspect == null
              ? _allAspects.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.hub_outlined,
                      title: '저장된 어스펙트 데이터가 없습니다.',
                      subtitle: '내담자를 등록하면 자동으로 계산됩니다.',
                    )
                  : _buildAspectList()
              : _buildAspectResultsView(),
        ),
      ],
    );
  }

  Widget _buildAspectSearchHeader() {
    final selectedLabel = _selectedAspect != null
        ? AstrologyService.translateAspect(_selectedAspect!)
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildSearchField(
            controller: _aspectSearchController,
            hint: '어스펙트 검색 (예: 토성, 스퀘어)',
            onChanged: _filterAspects,
            onClear: () {
              setState(() {
                _aspectSearchController.clear();
                _selectedAspect = null;
                _aspectResults = [];
                _filterAspects('');
              });
            },
            showClear: _aspectSearchController.text.isNotEmpty ||
                _selectedAspect != null,
          ),
          if (selectedLabel != null) ...[
            const SizedBox(height: 12),
            _buildSelectedTagBanner(
              tag: selectedLabel,
              subtitle: '해당 내담자: ${_aspectResults.length}명',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAspectList() {
    // 어스펙트를 타입별로 분류해서 보여주기 (Square/Opposition 먼저)
    final tenseIndices = _filteredAspectIndices
        .where((i) => _allAspects[i].contains('Square') || _allAspects[i].contains('Opposition'))
        .toList();
    final softIndices = _filteredAspectIndices
        .where((i) => !_allAspects[i].contains('Square') && !_allAspects[i].contains('Opposition'))
        .toList();
    final ordered = [...tenseIndices, ...softIndices];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ordered.length,
      itemBuilder: (context, idx) {
        final i = ordered[idx];
        final rawKey = _allAspects[i];
        final label = _allAspectLabels[i];
        final isTense = rawKey.contains('Square') || rawKey.contains('Opposition');
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(
              isTense ? Icons.warning_amber_rounded : Icons.star_border_rounded,
              color: isTense ? Colors.redAccent : Themes.gold,
            ),
            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () => _searchByAspect(rawKey),
          ),
        );
      },
    );
  }

  Widget _buildAspectResultsView() {
    if (_aspectResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search_rounded,
        title: '해당 어스펙트를 가진 내담자가 없습니다.',
      );
    }

    final selectedLabel = AstrologyService.translateAspect(_selectedAspect!);
    final isTense = _selectedAspect!.contains('Square') || _selectedAspect!.contains('Opposition');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _aspectResults.length,
      itemBuilder: (context, index) {
        final result = _aspectResults[index];
        final c = result.client;

        String sun = '', asc = '';
        for (final p in c.placements) {
          if (p.startsWith('Sun in ')) sun = AstrologyService.zodiacKorean[p.replaceFirst('Sun in ', '')] ?? '';
          if (p.startsWith('Ascendant in ')) asc = AstrologyService.zodiacKorean[p.replaceFirst('Ascendant in ', '')] ?? '';
        }

        Color matchColor = Colors.grey;
        String matchLabel = '미기록';
        if (result.aiMatchLevel == 'match') { matchColor = Colors.green; matchLabel = '일치'; }
        else if (result.aiMatchLevel == 'partial') { matchColor = Colors.amber; matchLabel = '부분일치'; }
        else if (result.aiMatchLevel == 'mismatch') { matchColor = Colors.redAccent; matchLabel = '불일치'; }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientDetailsScreen(clientId: c.id)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTense
                    ? Colors.redAccent.withValues(alpha: 0.25)
                    : Themes.gold.withValues(alpha: 0.18),
              ),
              boxShadow: [Themes.cardShadow(Theme.of(context).brightness == Brightness.dark)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isTense ? Colors.redAccent.withValues(alpha: 0.7) : Themes.gold,
                      child: Text(c.name.isNotEmpty ? c.name[0] : 'N',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            if (result.needsReview) ...[const SizedBox(width: 6), const Icon(Icons.flag_rounded, color: Colors.orangeAccent, size: 14)],
                          ]),
                          Text('☀️ $sun  상승: $asc', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: matchColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: matchColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(matchLabel, style: TextStyle(fontSize: 11, color: matchColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                  ],
                ),
                if (result.observation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(result.observation,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],
                if (c.clinicalTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5, runSpacing: 4,
                    children: c.clinicalTags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Text(tag, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  // ══════════════════════════════════════════════════════════════════════════
  // 모드 1: 상담 태그 통계
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildConsultStatsMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildConsultSearchHeader(),
        Expanded(
          child: _selectedConsultTag == null
              ? _buildTagList(_filteredConsultTags, _calculateConsultStats)
              : _buildConsultStatsView(),
        ),
      ],
    );
  }

  Widget _buildConsultSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildSearchField(
            controller: _consultSearchController,
            hint: '상담 태그 검색 (예: #결정장애)',
            onChanged: _filterConsultTags,
            onClear: () {
              setState(() {
                _consultSearchController.clear();
                _selectedConsultTag = null;
                _filterConsultTags('');
              });
            },
            showClear: _consultSearchController.text.isNotEmpty ||
                _selectedConsultTag != null,
          ),
          if (_selectedConsultTag != null) ...[
            const SizedBox(height: 12),
            _buildSelectedTagBanner(
              tag: _selectedConsultTag!,
              subtitle: '해당 임상 내담자: $_consultTotal명',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsultStatsView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Themes.gold,
            labelColor: Themes.gold,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '행성 배치 빈도'),
              Tab(text: '격각 빈도'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStatsList(_placementStats, Themes.gold),
                _buildStatsList(_aspectStats, Colors.redAccent, isAspect: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 모드 2: 임상 패턴 검색 (Phase 3)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildClinicalPatternMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildClinicalSearchHeader(),
        Expanded(
          child: _selectedClinicalTag == null
              ? _allClinicalTags.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.label_off_rounded,
                      title: '저장된 임상 태그가 없습니다.',
                      subtitle: '차트 화면 하단 "임상 관찰 노트"에서 태그를 추가해 주세요.',
                    )
                  : _buildTagList(_filteredClinicalTags, _searchByClinicaltag)
              : _buildPatternResultsView(),
        ),
      ],
    );
  }

  Widget _buildClinicalSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildSearchField(
            controller: _clinicalSearchController,
            hint: '임상 관찰 태그 검색 (예: #아버지이슈)',
            onChanged: _filterClinicalTags,
            onClear: () {
              setState(() {
                _clinicalSearchController.clear();
                _selectedClinicalTag = null;
                _patternResults = [];
                _filterClinicalTags('');
              });
            },
            showClear: _clinicalSearchController.text.isNotEmpty ||
                _selectedClinicalTag != null,
          ),
          if (_selectedClinicalTag != null) ...[
            const SizedBox(height: 12),
            _buildSelectedTagBanner(
              tag: _selectedClinicalTag!,
              subtitle: '해당 내담자: ${_patternResults.length}명',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternResultsView() {
    if (_patternResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search_rounded,
        title: '해당 태그를 가진 내담자가 없습니다.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _patternResults.length,
      itemBuilder: (context, index) {
        final result = _patternResults[index];
        final c = result.client;

        // Sun / Asc 사인
        String sun = '', asc = '';
        for (final p in c.placements) {
          if (p.startsWith('Sun in ')) {
            sun = AstrologyService.zodiacKorean[p.replaceFirst('Sun in ', '')] ?? '';
          } else if (p.startsWith('Ascendant in ')) {
            asc = AstrologyService.zodiacKorean[p.replaceFirst('Ascendant in ', '')] ?? '';
          }
        }

        Color matchColor = Colors.grey;
        String matchLabel = '미기록';
        if (result.aiMatchLevel == 'match') {
          matchColor = Colors.green;
          matchLabel = '일치';
        } else if (result.aiMatchLevel == 'partial') {
          matchColor = Colors.amber;
          matchLabel = '부분일치';
        } else if (result.aiMatchLevel == 'mismatch') {
          matchColor = Colors.redAccent;
          matchLabel = '불일치';
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientDetailsScreen(clientId: c.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.needsReview
                    ? Colors.orangeAccent.withValues(alpha: 0.5)
                    : Themes.gold.withValues(alpha: 0.18),
              ),
              boxShadow: [
                Themes.cardShadow(
                    Theme.of(context).brightness == Brightness.dark)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 이름 아바타
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Themes.gold,
                      child: Text(
                        c.name.isNotEmpty ? c.name[0] : 'N',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              if (result.needsReview) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.flag_rounded,
                                    color: Colors.orangeAccent, size: 14),
                              ],
                            ],
                          ),
                          Text(
                            '☀️ $sun  상승: $asc',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // AI 일치도 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: matchColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: matchColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        matchLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: matchColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.grey, size: 18),
                  ],
                ),
                if (result.observation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.observation,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                // 태그 목록
                if (c.clinicalTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: c.clinicalTags.map((tag) {
                      final isSelected = tag == _selectedClinicalTag;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Themes.gold.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isSelected
                                ? Themes.gold.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Themes.gold : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 공통 위젯
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
    required bool showClear,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: Themes.gold),
        suffixIcon: showClear
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                onPressed: onClear,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Themes.gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSelectedTagBanner({required String tag, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Themes.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Themes.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '선택된 태그: $tag',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Themes.gold, fontSize: 13),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList(List<String> tags, ValueChanged<String> onTap) {
    if (tags.isEmpty) {
      return _buildEmptyState(
        icon: Icons.label_off_rounded,
        title: '저장된 태그가 없습니다.',
        subtitle: '상담 기록이나 임상 관찰 노트에서 태그를 추가해 주세요.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.label_rounded, color: Themes.gold),
            title: Text(tag,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
            onTap: () => onTap(tag),
          ),
        );
      },
    );
  }

  Widget _buildStatsList(List<StatItem> items, Color barColor,
      {bool isAspect = false}) {
    if (items.isEmpty) {
      return const Center(
          child: Text('감지된 통계 데이터가 없습니다.',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final displayColor =
            (isAspect && item.isTense) ? Colors.redAccent : barColor;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item.label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    '${item.count}명 (${item.percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: displayColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.percentage / 100,
                  backgroundColor: Colors.grey.withValues(alpha: 0.15),
                  color: displayColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
      {required IconData icon, required String title, String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Themes.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

// ── 데이터 모델 ──────────────────────────────────────────────────────────────

class StatItem {
  final String label;
  final int count;
  final double percentage;
  final bool isTense;

  StatItem({
    required this.label,
    required this.count,
    required this.percentage,
    this.isTense = false,
  });
}

class _ClientPatternResult {
  final Client client;
  final String observation;
  final String aiMatchLevel;
  final bool needsReview;

  _ClientPatternResult({
    required this.client,
    required this.observation,
    required this.aiMatchLevel,
    required this.needsReview,
  });
}
