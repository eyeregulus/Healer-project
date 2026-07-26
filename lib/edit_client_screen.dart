import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'astrology_service.dart';
import 'database_service.dart';
import 'google_sheets_service.dart';
import 'models/client.dart';
import 'themes.dart';
import 'app_snackbar.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;
  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _timeUnknown = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameController = TextEditingController(text: c.name);
    _noteController = TextEditingController(text: c.note);

    // birthPlace: "나라/도시"
    final placeParts = c.birthPlace.split('/');
    _countryController = TextEditingController(
        text: placeParts.isNotEmpty ? placeParts[0] : '');
    _cityController = TextEditingController(
        text: placeParts.length > 1 ? placeParts[1] : '');

    _selectedDate = c.birthDate;

    // 시간 Unknown 여부 체크
    if (c.birthTime == 'Unknown' || c.birthTime == '00:00') {
      _timeUnknown = true;
      _selectedTime = const TimeOfDay(hour: 12, minute: 0);
    } else {
      final parts = c.birthTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 12,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: Themes.gold, onPrimary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: Themes.gold, onPrimary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final country = _countryController.text.trim();
      final city = _cityController.text.trim();

      final query = city.isNotEmpty ? '$city, $country' : country;
      final geoUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final res = await http.get(geoUrl, headers: {'User-Agent': 'HealerProjectApp/1.0'});
      if (res.statusCode != 200) throw Exception('위치 정보를 가져올 수 없습니다.');
      final List<dynamic> jsonResult = jsonDecode(res.body);
      if (jsonResult.isEmpty) throw Exception('해당 도시($query)를 찾을 수 없습니다.');

      final geoData = jsonResult[0];
      final lat = double.parse(geoData['lat'].toString());
      final lon = double.parse(geoData['lon'].toString());

      final tzUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&timezone=auto');
      final tzRes = await http.get(tzUrl);
      String timezoneString = 'Asia/Seoul';
      if (tzRes.statusCode == 200) {
        final tzJson = jsonDecode(tzRes.body);
        timezoneString = tzJson['timezone'] as String? ?? 'Asia/Seoul';
      }

      final location = tz.getLocation(timezoneString);
      final effectiveTime = _timeUnknown
          ? const TimeOfDay(hour: 12, minute: 0)
          : _selectedTime;
      final tzDate = tz.TZDateTime(location, _selectedDate.year,
          _selectedDate.month, _selectedDate.day,
          effectiveTime.hour, effectiveTime.minute);
      final tzOffset = tzDate.timeZoneOffset.inMinutes / 60.0;

      final birthTimeStr = _timeUnknown
          ? 'Unknown'
          : '${effectiveTime.hour.toString().padLeft(2, '0')}:${effectiveTime.minute.toString().padLeft(2, '0')}';

      final chart = AstrologyService.calculateChart(
        birthDate: _selectedDate,
        birthTime: _timeUnknown ? '12:00' : birthTimeStr,
        latitude: lat,
        longitude: lon,
        timezoneOffset: tzOffset,
      );

      await DatabaseService.isar.writeTxn(() async {
        final fresh = await DatabaseService.isar.clients.get(widget.client.id);
        if (fresh == null) return;
        fresh
          ..name = _nameController.text.trim()
          ..birthDate = _selectedDate
          ..birthTime = birthTimeStr
          ..birthPlace = '$country/$city'
          ..latitude = lat
          ..longitude = lon
          ..timezoneOffset = tzOffset
          ..placements = chart['placements']!
          ..aspects = chart['aspects']!
          ..note = _noteController.text.trim();
        await DatabaseService.isar.clients.put(fresh);
        GoogleSheetsService.upsertClient(fresh);
      });

      if (mounted) {
        AppSnackBar.show(context, message: '수정되었습니다.');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) AppSnackBar.show(context, message: '수정 실패: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일';
    final timeStr = _timeUnknown ? 'Unknown' : _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내담자 프로필 수정'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '내담자 이름',
                    labelStyle: TextStyle(color: Themes.gold),
                    border: InputBorder.none,
                    icon: Icon(Icons.person_rounded, color: Themes.gold),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '이름을 입력해 주세요.' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 생년월일
              _buildCard(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(children: [
                      const Icon(Icons.calendar_month_rounded, color: Themes.gold),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('생년월일',
                            style: TextStyle(fontSize: 12, color: Themes.gold)),
                        const SizedBox(height: 4),
                        Text(dateStr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ]),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 시간 + Unknown 체크
              _buildCard(
                child: Column(
                  children: [
                    InkWell(
                      onTap: _timeUnknown ? null : () => _selectTime(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(children: [
                          Icon(Icons.access_time_rounded,
                              color: _timeUnknown
                                  ? Colors.grey
                                  : Themes.gold),
                          const SizedBox(width: 16),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('태어난 시간',
                                    style: TextStyle(
                                        fontSize: 12, color: Themes.gold)),
                                const SizedBox(height: 4),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _timeUnknown
                                        ? Colors.grey
                                        : null,
                                  ),
                                ),
                              ]),
                        ]),
                      ),
                    ),
                    // Unknown 체크박스
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Checkbox(
                          value: _timeUnknown,
                          onChanged: (v) =>
                              setState(() => _timeUnknown = v ?? false),
                          activeColor: Themes.gold,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Text('출생 시간 알 수 없음 (Unknown)',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 출생지
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      child: TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: '나라',
                          labelStyle:
                              TextStyle(color: Themes.gold, fontSize: 13),
                          border: InputBorder.none,
                          icon: Icon(Icons.public_rounded,
                              color: Themes.gold, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? '필수' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: '도시',
                          labelStyle:
                              TextStyle(color: Themes.gold, fontSize: 13),
                          border: InputBorder.none,
                          icon: Icon(Icons.location_city_rounded,
                              color: Themes.gold, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? '필수' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 메모
              const Text('기타 메모',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Themes.gold)),
              const SizedBox(height: 8),
              _buildCard(
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '참고 메모',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Text('차트 재계산 및 수정 완료',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            Themes.cardShadow(
                Theme.of(context).brightness == Brightness.dark)
          ],
        ),
        child: child,
      );
}
