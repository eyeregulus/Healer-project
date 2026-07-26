import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'astrology_service.dart';
import 'database_service.dart';
import 'google_sheets_service.dart';
import 'models/consultation.dart';
import 'models/client.dart';
import 'app_snackbar.dart';
import 'themes.dart';

class TransitConsultationScreen extends StatefulWidget {
  final Client client;

  const TransitConsultationScreen({
    super.key,
    required this.client,
  });

  @override
  State<TransitConsultationScreen> createState() => _TransitConsultationScreenState();
}

class _TransitConsultationScreenState extends State<TransitConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _opinionController = TextEditingController();
  final _tagController = TextEditingController();
  final _observationController = TextEditingController();

  String _aiMatchLevel = ''; // match, partial, mismatch
  List<String> _tags = [];
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;

  late Map<String, double> _natalLongitudes;
  late Map<String, double> _transitLongitudes;
  late List<String> _transitAspects;
  late DateTime _seoulTime;

  @override
  void initState() {
    super.initState();
    _calculateTransitData();
  }

  void _calculateTransitData() {
    // 1. Calculate Natal Longitudes
    final natalData = AstrologyService.calculateNatalData(
      birthDate: widget.client.birthDate,
      birthTime: widget.client.birthTime,
      latitude: widget.client.latitude,
      longitude: widget.client.longitude,
      timezoneOffset: widget.client.timezoneOffset,
    );
    _natalLongitudes = natalData['longitudes'] as Map<String, double>;

    // 2. Seoul Time: UTC + 9 hours
    final nowUtc = DateTime.now().toUtc();
    _seoulTime = nowUtc.add(const Duration(hours: 9));

    // 3. Calculate Transit Longitudes (current UTC time)
    _transitLongitudes = AstrologyService.calculateTransitLongitudes();

    // 4. Calculate Transit-to-Natal aspects (max orb 3 degrees)
    _transitAspects = AstrologyService.calculateTransitToNatalAspects(
      natalLongitudes: _natalLongitudes,
      transitLongitudes: _transitLongitudes,
      maxOrb: 3.0,
    );
  }

  Future<void> _runAiTransitAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await AiService.analyzeTransitConsultation(
        placements: widget.client.placements,
        aspects: widget.client.aspects,
        transitAspects: _transitAspects.map((a) => _formatTransitAspectText(a)).toList(),
        complaint: _complaintController.text.trim(),
      );

      setState(() {
        _opinionController.text = result.opinion;
        _tags = result.recommendedTags;
        _hasAnalyzed = true;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        AppSnackBar.show(context, message: '트랜짓 AI 분석 실패: $e');
      }
    }
  }

  String _formatTransitAspectText(String aspect) {
    final parts = aspect.split('-');
    if (parts.length < 3) return aspect;
    final tp = parts[0]; // transit planet
    final np = parts[1]; // natal planet
    final type = parts[2]; // aspect type
    return 'Transit $tp ${AstrologyService.aspectSymbol[type] ?? type} Natal $np';
  }

  String _translateTransitAspect(String aspect) {
    final parts = aspect.split('-');
    if (parts.length < 3) return aspect;
    final tp = parts[0];
    final np = parts[1];
    final type = parts[2];

    final tpKorean = AstrologyService.planetKorean[tp] ?? tp;
    final npKorean = AstrologyService.planetKorean[np] ?? np;
    final tpSymbol = AstrologyService.planetSymbol[tp] ?? '';
    final npSymbol = AstrologyService.planetSymbol[np] ?? '';
    final aSymbol = AstrologyService.aspectSymbol[type] ?? type;

    return 'T $tpKorean ($tpSymbol) $aSymbol N $npKorean ($npSymbol)';
  }

  void _addCustomTag() {
    final rawText = _tagController.text.trim();
    if (rawText.isEmpty) return;

    final tag = rawText.startsWith('#') ? rawText : '#$rawText';

    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    } else {
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  String _formatDateTime(DateTime dt, {bool includeSeconds = false}) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    if (includeSeconds) {
      final sec = dt.second.toString().padLeft(2, '0');
      return '$y-$m-$d $h:$min:$sec';
    }
    return '$y-$m-$d $h:$min';
  }

  Future<void> _saveConsultation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_opinionController.text.trim().isEmpty) {
      AppSnackBar.show(context, message: 'AI 분석 소견을 먼저 생성해 주세요.');
      return;
    }

    try {
      final formattedTime = _formatDateTime(_seoulTime);
      final transitHeader = '[T AI 분석 (서울: $formattedTime)]\n';
      
      final consultation = Consultation()
        ..clientId = widget.client.id
        ..clientName = widget.client.name
        ..complaint = _complaintController.text.trim()
        ..aiOpinion = '$transitHeader${_opinionController.text.trim()}'
        ..finalTags = _tags
        ..clinicalObservation = _observationController.text.trim()
        ..aiMatchLevel = _aiMatchLevel
        ..createdAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.consultations.put(consultation);
        
        final freshClient = await DatabaseService.isar.clients.get(widget.client.id);
        if (freshClient != null) {
          final merged = Set<String>.from(freshClient.clinicalTags)..addAll(_tags);
          freshClient.clinicalTags = merged.toList();
          await DatabaseService.isar.clients.put(freshClient);
          GoogleSheetsService.upsertClient(freshClient);
        }
      });

      GoogleSheetsService.upsertConsultation(consultation);

      if (mounted) {
        AppSnackBar.show(context, message: '트랜짓 상담이 등록되었습니다.');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: '저장 실패: $e');
      }
    }
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _opinionController.dispose();
    _tagController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime = _formatDateTime(_seoulTime, includeSeconds: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.client.name} 님 트랜짓 AI 상담'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Transit Reference Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Themes.gold.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  boxShadow: [Themes.cardShadow(isDark)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: Themes.gold, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '트랜짓 분석 기준 (Transit Reference)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Themes.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '위치: 대한민국 서울 (Seoul, South Korea)',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '시간: $formattedTime KST (UTC+9)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Active Transit Aspects List
              const Text(
                '실시간 활성화된 트랜짓 영향 (오차범위 3° 이내)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
              if (_transitAspects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: const Center(
                    child: Text(
                      '현재 오차범위 3도 이내로 강하게 활성화된 각도가 없습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _transitAspects.map((aspect) {
                    final isTense = aspect.contains('Square') || aspect.contains('Opposition');
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isTense
                            ? Colors.redAccent.withValues(alpha: 0.08)
                            : Themes.gold.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isTense
                              ? Colors.redAccent.withValues(alpha: 0.35)
                              : Themes.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _translateTransitAspect(aspect),
                        style: TextStyle(
                          fontSize: 13,
                          color: isTense ? Colors.redAccent : Themes.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              // 3. Complaint input
              const Text(
                '내담자 고민 및 주호소 문제 (Complaint)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
                child: TextFormField(
                  controller: _complaintController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '현재 내담자가 고민하고 있는 구체적 문제나 고통을 입력해 주세요.',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '고민 내용을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 4. AI Request Button
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _runAiTransitAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_isAnalyzing ? '실시간 트랜짓 분석 중...' : 'AI 실시간 트랜짓 분석 요청'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              // 5. AI Opinion Section
              if (_hasAnalyzed || _opinionController.text.isNotEmpty) ...[
                const Text(
                  'AI 실시간 트랜짓 분석 및 솔루션',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
                ),
                const SizedBox(height: 8),
                _buildCardContainer(
                  child: TextFormField(
                    controller: _opinionController,
                    maxLines: 15,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Tags Management
                const Text(
                  '임상 분석 태그',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
                ),
                const SizedBox(height: 8),
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return InputChip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIconColor: Colors.redAccent,
                        backgroundColor: Themes.gold.withValues(alpha: 0.1),
                        side: const BorderSide(color: Themes.gold),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: '태그 직접 입력 (예: #토성_성장통)',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _addCustomTag(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                     SizedBox(
                       height: 48,
                       child: ElevatedButton(
                         onPressed: _addCustomTag,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Themes.gold,
                           foregroundColor: Colors.black,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('추가'),
                       ),
                     ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7. Session Observation Note & Match Level
                const Text(
                  '임상 관찰 및 AI 피드백',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'AI 트랜짓 분석이 실제 내담자 상태와 얼마나 일치하나요?',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _matchChip('일치', 'match', Colors.green),
                    _matchChip('부분 일치', 'partial', Colors.orange),
                    _matchChip('불일치', 'mismatch', Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '상담사 임상 관찰 노트',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Themes.gold),
                ),
                const SizedBox(height: 8),
                _buildCardContainer(
                  child: TextFormField(
                    controller: _observationController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'AI의 조언 외에 상담사가 실제 임상에서 포착한 내담자의 반응이나 중요 관찰 내용을 자유롭게 적어주세요.',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Save button
                ElevatedButton(
                  onPressed: _saveConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('상담 저장 및 동기화', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _matchChip(String label, String value, Color color) {
    final isSelected = _aiMatchLevel == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _aiMatchLevel = selected ? value : '';
        });
      },
      selectedColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: isSelected ? color : Colors.grey.withValues(alpha: 0.5), width: 1.5),
      labelStyle: TextStyle(
        color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}
