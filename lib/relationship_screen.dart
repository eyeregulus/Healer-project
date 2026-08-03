import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'database_service.dart';
import 'models/client.dart';
import 'astrology_service.dart';
import 'ai_service.dart';
import 'add_client_screen.dart';
import 'themes.dart';
import 'app_snackbar.dart';

class RelationshipScreen extends StatefulWidget {
  const RelationshipScreen({super.key});

  @override
  State<RelationshipScreen> createState() => _RelationshipScreenState();
}

class _RelationshipScreenState extends State<RelationshipScreen>
    with SingleTickerProviderStateMixin {
  Client? _myProfile;
  Client? _targetPartner;

  TabController? _tabController;
  bool _isAiLoading = false;
  String _aiReport = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _generateAiRelationshipReport() async {
    if (_myProfile == null || _targetPartner == null) return;

    setState(() {
      _isAiLoading = true;
      _aiReport = '';
    });

    try {
      final dataA = AstrologyService.calculateNatalData(
        birthDate: _myProfile!.birthDate,
        birthTime: _myProfile!.birthTime,
        latitude: _myProfile!.latitude,
        longitude: _myProfile!.longitude,
        timezoneOffset: _myProfile!.timezoneOffset,
      );

      final dataB = AstrologyService.calculateNatalData(
        birthDate: _targetPartner!.birthDate,
        birthTime: _targetPartner!.birthTime,
        latitude: _targetPartner!.latitude,
        longitude: _targetPartner!.longitude,
        timezoneOffset: _targetPartner!.timezoneOffset,
      );

      final synastry = AstrologyService.calculateSynastryData(
        longitudesA: dataA['longitudes'] as Map<String, double>,
        cuspsA: (dataA['cusps'] as List).cast<double>(),
        longitudesB: dataB['longitudes'] as Map<String, double>,
        cuspsB: (dataB['cusps'] as List).cast<double>(),
      );

      final composite = AstrologyService.calculateCompositeData(
        longitudesA: dataA['longitudes'] as Map<String, double>,
        cuspsA: (dataA['cusps'] as List).cast<double>(),
        longitudesB: dataB['longitudes'] as Map<String, double>,
        cuspsB: (dataB['cusps'] as List).cast<double>(),
      );

      final isTimeUnknownA =
          _myProfile!.birthTime == 'Unknown' ||
          !_myProfile!.birthTime.contains(':');
      final isTimeUnknownB =
          _targetPartner!.birthTime == 'Unknown' ||
          !_targetPartner!.birthTime.contains(':');
      final isAnyTimeUnknown = isTimeUnknownA || isTimeUnknownB;

      final prompt = '''
내담자 A (${_myProfile!.name}):
- 생년월일: ${_myProfile!.birthDate.toIso8601String().substring(0, 10)} ${_myProfile!.birthTime}
- 주요 배치: ${_myProfile!.placements.take(6).join(', ')}

상대방 B (${_targetPartner!.name}):
- 생년월일: ${_targetPartner!.birthDate.toIso8601String().substring(0, 10)} ${_targetPartner!.birthTime}
- 주요 배치: ${_targetPartner!.placements.take(6).join(', ')}

시나스트리 상호작용 (Aspects):
${(synastry['synastryAspects'] as List<String>).take(8).join('\n')}

컴포짓 합성 차트 배치 (Composite Placements):
${(composite['placements'] as List<String>).take(8).join('\n')}

위 데이터를 바탕으로 분석하세요. ${isAnyTimeUnknown ? '(주의: 한 명 이상 출생 시간 미상이므로 ℎ 영역/포지션 및 ASC/MC 해석은 완전 배제하고, 사인 중심 캐릭터/에센셜 디그니티/지배 행성 상태/행성 간 어스펙트 상호작용 중심으로만 서술하세요.)' : ''}

1. 두 사람이 만나서 관계를 형성할 때 어떤 에너지를 공유하게 되는가? (사인 및 행성 어스펙트 중심)
2. 두 사람이 대화할 때 어떤 주제/이야기에 강력한 흥미와 공감을 느끼는가? (수성/금성/태양 각도 중심)
3. 서로의 캐릭터(사인/디그니티/룰러 상태)와 어스펙트 시선에서 잘 맞고 유의해야 할 포인트는 무엇인가?
''';

      final report = await AiService.generateAnalysis(
        prompt,
        isTimeUnknown: isAnyTimeUnknown,
      );
      if (mounted) {
        setState(() {
          _aiReport = report;
          _isAiLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAiLoading = false;
        });
        AppSnackBar.show(context, message: 'AI 리포트 생성 중 오류: $e');
      }
    }
  }

  void _showClientSelectorDialog({required bool isSelectingSelf}) async {
    final clients = await DatabaseService.isar.clients.where().findAll();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSelectingSelf ? '내 프로필 선택' : '상대방 선택',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddClientScreen(),
                          ),
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('+ 새 멤버 등록'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: clients.isEmpty
                    ? const Center(child: Text('등록된 내담자가 없습니다.'))
                    : ListView.builder(
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final c = clients[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Themes.gold.withValues(alpha: 0.2),
                              child: Text(
                                c.name.isNotEmpty ? c.name[0] : 'N',
                                style: const TextStyle(
                                  color: Themes.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${c.birthDate.year}.${c.birthDate.month}.${c.birthDate.day} (${c.birthPlace})',
                            ),
                            onTap: () {
                              setState(() {
                                if (isSelectingSelf) {
                                  _myProfile = c;
                                } else {
                                  _targetPartner = c;
                                }
                                _aiReport = '';
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonSelectionCard({
    required String label,
    required Client? client,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final isUnknown = client != null && (client.birthTime == 'Unknown' || !client.birthTime.contains(':'));

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: client != null
                  ? Themes.gold
                  : Colors.grey.withValues(alpha: 0.3),
              width: client != null ? 1.5 : 1.0,
            ),
            boxShadow: [Themes.cardShadow(isDark)],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Themes.gold,
                ),
              ),
              const SizedBox(height: 8),
              if (client != null) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Themes.gold.withValues(alpha: 0.2),
                  child: Text(
                    client.name[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Themes.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isUnknown
                      ? '${client.birthDate.year}.${client.birthDate.month}.${client.birthDate.day} Unknown ?'
                      : '${client.birthDate.year}.${client.birthDate.month}.${client.birthDate.day} ${client.birthTime}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  '선택하기',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoListTile(String title, List<String> items, {bool isTimeUnknown = false}) {
    final filteredItems = isTimeUnknown
        ? items.where((item) {
            final lower = item.toLowerCase();
            return !lower.contains('house') &&
                !lower.startsWith('ascendant in') &&
                !lower.startsWith('mc in');
          }).toList()
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Themes.gold,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: filteredItems.take(10).map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Themes.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Themes.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                AstrologyService.translatePlacement(item),
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('관계 & 궁합 분석 (시나스트리/컴포짓)'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👥 나 + 상대방 선택 비교 카드
            Row(
              children: [
                _buildPersonSelectionCard(
                  label: '나 (My Natal)',
                  client: _myProfile,
                  onTap: () => _showClientSelectorDialog(isSelectingSelf: true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.favorite_rounded, color: Colors.redAccent),
                ),
                _buildPersonSelectionCard(
                  label: '상대방 (Partner)',
                  client: _targetPartner,
                  onTap: () => _showClientSelectorDialog(isSelectingSelf: false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 두 사람이 모두 선택되지 않은 경우 안내
            if (_myProfile == null || _targetPartner == null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Themes.gold.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: Themes.gold.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '나와 상대방의 프로필을 선택해 주세요.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '상단 카드를 눌러 등록된 멤버를 선택하거나\n새로운 사람의 생년월일을 등록할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 📊 두 사람의 정보 나열 카드
              Builder(
                builder: (context) {
                  final isTimeUnknownA = _myProfile!.birthTime == 'Unknown' || !_myProfile!.birthTime.contains(':');
                  final isTimeUnknownB = _targetPartner!.birthTime == 'Unknown' || !_targetPartner!.birthTime.contains(':');
                  final isAnyUnknown = isTimeUnknownA || isTimeUnknownB;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Themes.gold.withValues(alpha: 0.2)),
                      boxShadow: [Themes.cardShadow(isDark)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '📌 각자의 네이탈 주요 배치 비교',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isAnyUnknown)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber, width: 1),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded, size: 13, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      'Unknown ? (사인/어스펙트 중심)',
                                      style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (isAnyUnknown) ...[
                          const SizedBox(height: 8),
                          Text(
                            '※ 출생 시간을 모르는 내담자가 포함되어 있습니다. ℎ(하우스 영역) 및 ASC/MC 관련 포지션 분석은 제외하고, 황도 12궁 사인 캐릭터, 에센셜 디그니티, 지배 행성 상태 및 행성 어스펙트를 중심으로 해석합니다.',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                        ],
                    const SizedBox(height: 12),
                    _buildInfoListTile(
                      '👤 ${_myProfile!.name} 님의 주요 배치',
                      _myProfile!.placements,
                      isTimeUnknown: isTimeUnknownA,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoListTile(
                      '👤 ${_targetPartner!.name} 님의 주요 배치',
                      _targetPartner!.placements,
                      isTimeUnknown: isTimeUnknownB,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

              // 탭 바 (시나스트리 vs 컴포짓)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Themes.gold.withValues(alpha: 0.2)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Themes.gold,
                  labelColor: Themes.gold,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.sync_alt_rounded),
                      text: '시나스트리 (에너지/대화)',
                    ),
                    Tab(
                      icon: Icon(Icons.hub_rounded),
                      text: '컴포짓 (합성 차트)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 탭 뷰 내용
              SizedBox(
                height: 240,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. 시나스트리 뷰
                    _buildSynastryView(),
                    // 2. 컴포짓 뷰
                    _buildCompositeView(),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 🤖 AI 종합 관계 리포트 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAiLoading ? null : _generateAiRelationshipReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isAiLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _isAiLoading
                        ? 'AI가 궁합 및 대화 에너지를 분석 중입니다...'
                        : '🤖 AI 관계 & 대화 에너지 상세 분석 생성',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (_aiReport.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Themes.gold.withValues(alpha: 0.3)),
                    boxShadow: [Themes.cardShadow(isDark)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Themes.gold),
                          const SizedBox(width: 8),
                          Text(
                            'AI 심층 궁합 리포트',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      SelectableText(
                        _aiReport,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSynastryView() {
    final dataA = AstrologyService.calculateNatalData(
      birthDate: _myProfile!.birthDate,
      birthTime: _myProfile!.birthTime,
      latitude: _myProfile!.latitude,
      longitude: _myProfile!.longitude,
      timezoneOffset: _myProfile!.timezoneOffset,
    );

    final dataB = AstrologyService.calculateNatalData(
      birthDate: _targetPartner!.birthDate,
      birthTime: _targetPartner!.birthTime,
      latitude: _targetPartner!.latitude,
      longitude: _targetPartner!.longitude,
      timezoneOffset: _targetPartner!.timezoneOffset,
    );

    final synastry = AstrologyService.calculateSynastryData(
      longitudesA: dataA['longitudes'] as Map<String, double>,
      cuspsA: (dataA['cusps'] as List).cast<double>(),
      longitudesB: dataB['longitudes'] as Map<String, double>,
      cuspsB: (dataB['cusps'] as List).cast<double>(),
    );

    final aspects = synastry['synastryAspects'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Themes.gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔮 주요 시나스트리 어스펙트 (상호작용)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: aspects.isEmpty
                ? const Center(child: Text('주요 어스펙트가 없습니다.'))
                : ListView.builder(
                    itemCount: aspects.length,
                    itemBuilder: (context, index) {
                      final item = aspects[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.star_border_purple500_rounded,
                                size: 14, color: Themes.gold),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositeView() {
    final dataA = AstrologyService.calculateNatalData(
      birthDate: _myProfile!.birthDate,
      birthTime: _myProfile!.birthTime,
      latitude: _myProfile!.latitude,
      longitude: _myProfile!.longitude,
      timezoneOffset: _myProfile!.timezoneOffset,
    );

    final dataB = AstrologyService.calculateNatalData(
      birthDate: _targetPartner!.birthDate,
      birthTime: _targetPartner!.birthTime,
      latitude: _targetPartner!.latitude,
      longitude: _targetPartner!.longitude,
      timezoneOffset: _targetPartner!.timezoneOffset,
    );

    final composite = AstrologyService.calculateCompositeData(
      longitudesA: dataA['longitudes'] as Map<String, double>,
      cuspsA: (dataA['cusps'] as List).cast<double>(),
      longitudesB: dataB['longitudes'] as Map<String, double>,
      cuspsB: (dataB['cusps'] as List).cast<double>(),
    );

    final placements = composite['placements'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Themes.gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌌 컴포짓 차트 배치 (합성 에너지)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: placements.length,
              itemBuilder: (context, index) {
                final item = placements[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_7_rounded,
                          size: 14, color: Themes.gold),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          AstrologyService.translatePlacement(item),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
