import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'database_service.dart';
import 'google_sheets_service.dart';
import 'models/consultation.dart';
import 'app_snackbar.dart';
import 'themes.dart';

class AddConsultationScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final List<String> placements;
  final List<String> aspects;

  const AddConsultationScreen({
    super.key,
    required this.clientId,
    required this.clientName,
    required this.placements,
    required this.aspects,
  });

  @override
  State<AddConsultationScreen> createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _opinionController = TextEditingController();
  final _tagController = TextEditingController();
  
  List<String> _tags = [];
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;

  Future<void> _runAiAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await AiService.analyzeConsultation(
        placements: widget.placements,
        aspects: widget.aspects,
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
        AppSnackBar.show(context, message: 'AI 분석 실패: $e');
      }
    }
  }

  void _addCustomTag() {
    final rawText = _tagController.text.trim();
    if (rawText.isEmpty) return;

    // Auto-prefix with '#' if missing
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

  Future<void> _saveConsultation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_opinionController.text.trim().isEmpty) {
      AppSnackBar.show(context, message: 'AI 분석 소견을 먼저 생성해 주세요.');
      return;
    }

    try {
      final consultation = Consultation()
        ..clientId = widget.clientId
        ..clientName = widget.clientName
        ..complaint = _complaintController.text.trim()
        ..aiOpinion = _opinionController.text.trim()
        ..finalTags = _tags
        ..createdAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.consultations.put(consultation);
      });

      // 클라우드 동기화
      GoogleSheetsService.upsertConsultation(consultation);

      if (mounted) {
        AppSnackBar.show(context, message: '상담이 등록되었습니다.');
        Navigator.of(context).pop(true); // Return true to trigger refresh
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.clientName} 님 상담 기록'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 1: Complaint
              const Text(
                '고민 및 주호소 문제 (Complaint)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
                child: TextFormField(
                  controller: _complaintController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '내담자가 고통을 호소하는 현재 고민을 구체적으로 적어주세요.\n예: 결정장애로 이직 타이밍을 놓치고 무기력증에 시달립니다.',
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

              // AI Request Button
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _runAiAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology_rounded),
                label: Text(_isAnalyzing ? 'AI 임상 분석 중...' : 'AI 임상 분석 요청'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              if (_hasAnalyzed || _opinionController.text.isNotEmpty) ...[
                // Step 2: AI Opinion
                const Text(
                  'AI 분석 소견 (3대 원인)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Themes.gold),
                ),
                const SizedBox(height: 8),
                _buildCardContainer(
                  child: TextFormField(
                    controller: _opinionController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Step 3: Tags
                const Text(
                  '임상 키워드 태그 관리',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Themes.gold),
                ),
                const SizedBox(height: 8),
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: '새 태그 추가 (예: 우울증)',
                                hintStyle: TextStyle(fontSize: 13),
                                border: InputBorder.none,
                              ),
                              onFieldSubmitted: (_) => _addCustomTag(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: Themes.gold),
                            onPressed: _addCustomTag,
                          ),
                        ],
                      ),
                      if (_tags.isNotEmpty) ...[
                        const Divider(height: 10),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) {
                            return InputChip(
                              label: Text(tag, style: const TextStyle(color: Colors.black, fontSize: 12)),
                              backgroundColor: Themes.gold,
                              onDeleted: () => _removeTag(tag),
                              deleteIconColor: Colors.black,
                              padding: const EdgeInsets.all(4),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                ElevatedButton(
                  onPressed: _saveConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: const Text(
                    '상담 기록 저장',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Themes.cardShadow(Theme.of(context).brightness == Brightness.dark)],
      ),
      child: child,
    );
  }
}
