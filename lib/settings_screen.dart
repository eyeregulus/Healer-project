import 'package:flutter/material.dart';
import 'database_service.dart';
import 'google_sheets_service.dart';
import 'models/preference.dart';
import 'app_snackbar.dart';
import 'themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  final _modelController = TextEditingController();
  final _promptController = TextEditingController();
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final pref = await DatabaseService.isar.preferences.get(0) ?? Preference();
      setState(() {
        _apiKeyController.text = pref.apiKey;
        _endpointController.text = pref.customEndpoint;
        _modelController.text = pref.modelName;
        _promptController.text = pref.systemPrompt;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    try {
      final pref = Preference()
        ..id = 0
        ..apiKey = _apiKeyController.text.trim()
        ..customEndpoint = _endpointController.text.trim()
        ..modelName = _modelController.text.trim()
        ..systemPrompt = _promptController.text.trim();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.preferences.put(pref);
      });

      if (mounted) {
        AppSnackBar.show(context, message: '설정이 성공적으로 저장되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: '저장 실패: $e');
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    _modelController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Themes.gold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            
            // Section 3: Data Sync
            _buildSectionHeader('데이터 백업 및 동기화', Icons.cloud_sync_rounded),
            const SizedBox(height: 15),
            
            _buildSyncSection(),

            const SizedBox(height: 40),

            // Section 1: AI API Config
            _buildSectionHeader('AI API 설정', Icons.api_rounded),
            const SizedBox(height: 15),
            
            _buildTextField(
              controller: _apiKeyController,
              label: 'API Key',
              hint: 'sk-...',
              obscureText: _obscureApiKey,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                  color: Themes.gold,
                ),
                onPressed: () {
                  setState(() {
                    _obscureApiKey = !_obscureApiKey;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            
            _buildTextField(
              controller: _endpointController,
              label: 'API Endpoint URL',
              hint: 'https://api.openai.com/v1',
            ),
            const SizedBox(height: 15),
            
            _buildTextField(
              controller: _modelController,
              label: 'Model Name',
              hint: 'gpt-4o or claude-3-5-sonnet-20241022',
            ),
            
            const SizedBox(height: 30),

            // Section 2: Prompts
            _buildSectionHeader('점성학 분석 프롬프트 설정', Icons.psychology_rounded),
            const SizedBox(height: 15),
            
            _buildTextField(
              controller: _promptController,
              label: 'System Prompt Template',
              hint: '프롬프트를 입력하세요.',
              maxLines: 8,
            ),
            
            const SizedBox(height: 40),

            // Save Button
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: Themes.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Text(
                '설정 저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Themes.cardShadow(Theme.of(context).brightness == Brightness.dark)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '로컬에 저장된 모든 상담 데이터를 구글 시트(Healer DB)에 덮어씁니다.\n엑셀에서 편집하려면 먼저 동기화하세요.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSyncing ? null : _syncWithGoogleSheets,
            icon: _isSyncing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.cloud_upload_rounded),
            label: Text(_isSyncing ? '동기화 중...' : '구글 시트로 모두 백업하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.blueGrey.shade800 
                  : Colors.blue.shade50,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncWithGoogleSheets() async {
    setState(() => _isSyncing = true);
    try {
      await GoogleSheetsService.signIn();
      await GoogleSheetsService.pushAll(); // 전체 데이터 업로드
      
      if (mounted) {
        AppSnackBar.show(context, message: '구글 시트 동기화가 완료되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: '동기화 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Themes.gold, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Themes.cardShadow(Theme.of(context).brightness == Brightness.dark)],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Themes.gold, fontSize: 14),
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 14),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Themes.gold, width: 1.5),
          ),
        ),
      ),
    );
  }
}
