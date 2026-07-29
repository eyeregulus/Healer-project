import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isar/isar.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';
import 'database_service.dart';
import 'edit_client_screen.dart';
import 'google_sheets_service.dart';
import 'models/client.dart';
import 'models/consultation.dart';
import 'astrology_service.dart';
import 'app_snackbar.dart';
import 'themes.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (kDebugMode) return;
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Extract Sun, Moon, and Ascendant signs from placements
  Map<String, String> _getCoreSigns(List<String> placements) {
    String sun = '';
    String moon = '';
    String asc = '';

    for (final p in placements) {
      if (p.startsWith('Sun in ')) {
        final sign = p.replaceFirst('Sun in ', '');
        sun = AstrologyService.zodiacSymbol[sign] ?? sign;
      } else if (p.startsWith('Moon in ')) {
        final sign = p.replaceFirst('Moon in ', '');
        moon = AstrologyService.zodiacSymbol[sign] ?? sign;
      } else if (p.startsWith('Ascendant in ')) {
        final sign = p.replaceFirst('Ascendant in ', '');
        asc = AstrologyService.zodiacSymbol[sign] ?? sign;
      }
    }
    return {'Sun': sun, 'Moon': moon, 'Asc': asc};
  }

  Future<void> _deleteClient(Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('내담자 삭제'),
            content: Text(
              '정말로 ${client.name} 내담자의 모든 정보와 상담 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
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
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.clients.delete(client.id);
        final consultationsToDelete =
            await DatabaseService.isar.consultations
                .filter()
                .clientIdEqualTo(client.id)
                .findAll();
        for (final consultation in consultationsToDelete) {
          await DatabaseService.isar.consultations.delete(consultation.id);
          GoogleSheetsService.deleteConsultation(consultation.id);
        }
      });
      GoogleSheetsService.deleteClient(client.id);

      if (mounted) {
        AppSnackBar.show(context, message: '삭제되었습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch clients reactively from Isar database
    final clientsQuery = DatabaseService.isar.clients.where().anyId();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final textSecondaryColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 🔍 Premium Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Themes.gold.withValues(alpha: 0.15)),
                boxShadow: [Themes.cardShadow(true)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '내담자 이름 검색...',
                  hintStyle: TextStyle(
                    color: textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Themes.gold),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 👥 Reactive Client List
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: clientsQuery.watch(fireImmediately: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Themes.gold),
                  );
                }

                final allClients = snapshot.data ?? [];
                // Filter in memory for search query
                final filteredClients =
                    allClients.where((c) {
                      return c.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                    }).toList();

                if (filteredClients.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.people_outline_rounded,
                            size: 64,
                            color: Themes.gold.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '검색 결과가 없습니다.'
                                : '등록된 내담자가 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '다른 이름을 입력해 보세요.'
                                : '우측 하단의 + 버튼을 눌러 첫 내담자를 등록해 보세요!',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondaryColor.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    final signs = _getCoreSigns(client.placements);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Themes.gold.withValues(alpha: 0.15),
                        ),
                        boxShadow: [Themes.cardShadow(true)],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ClientDetailsScreen(
                                      clientId: client.id,
                                    ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Name Avatar
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Themes.gold,
                                        Themes.gold.withValues(alpha: 0.6),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      client.name.isNotEmpty
                                          ? client.name[0]
                                          : 'N',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Client Details Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${client.birthDate.year}년 ${client.birthDate.month}월 ${client.birthDate.day}일 ${client.birthTime} (${client.birthPlace})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Sign Badges
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            if (signs['Asc']!.isNotEmpty) ...[
                                              TextSpan(
                                                text: 'ASC ${signs['Asc']}',
                                                style: const TextStyle(
                                                  color: Color(0xFF64B5F6),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const TextSpan(text: '   '),
                                            ],
                                            if (signs['Sun']!.isNotEmpty) ...[
                                              TextSpan(
                                                text: '☉ ${signs['Sun']}',
                                                style: const TextStyle(
                                                  color: Color(0xFFE57373),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const TextSpan(text: '   '),
                                            ],
                                            if (signs['Moon']!.isNotEmpty)
                                              TextSpan(
                                                text: '☽ ${signs['Moon']}',
                                                style: const TextStyle(
                                                  color: Color(0xFF81C784),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: Colors.grey,
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditClientScreen(
                                                client: client,
                                              ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _deleteClient(client);
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 18,
                                                color: Themes.gold,
                                              ),
                                              SizedBox(width: 8),
                                              Text('수정하기'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: Colors.redAccent,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                '삭제하기',
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 📍 Floating Action Button to Add Client
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
        },
        backgroundColor: Themes.gold,
        tooltip: '내담자 등록',
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black),
      ),

      // 📢 Bottom Admob Banner
      bottomNavigationBar:
          _bannerAd != null
              ? SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
              : null,
    );
  }
}
