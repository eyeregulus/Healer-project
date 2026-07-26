import 'package:flutter/material.dart';
import 'astrology_service.dart';
import 'database_service.dart';
import 'google_sheets_service.dart';
import 'models/client.dart';
import 'themes.dart';
import 'app_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  bool _timeUnknown = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default to Seoul parameters
    _applySeoulDefaults();
  }

  void _applySeoulDefaults() {
    setState(() {
      _countryController.text = '한국';
      _cityController.text = '서울';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Themes.gold,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Themes.gold,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final country = _countryController.text.trim();
      final city = _cityController.text.trim();
      
      // 1. Nominatim API로 위도, 경도 가져오기 (한글 검색 지원)
      final query = city.isNotEmpty ? '$city, $country' : country;
      final geoUrl = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final res = await http.get(geoUrl, headers: {'User-Agent': 'HealerProjectApp/1.0'});
      if (res.statusCode != 200) {
        throw Exception('위치 정보를 가져올 수 없습니다. 네트워크 상태를 확인하세요.');
      }
      final List<dynamic> jsonResult = jsonDecode(res.body);
      if (jsonResult.isEmpty) {
        throw Exception('해당 도시($query)를 찾을 수 없습니다. 철자를 확인해주세요.');
      }
      
      final result = jsonResult[0];
      final lat = double.parse(result['lat'].toString());
      final lon = double.parse(result['lon'].toString());
      
      // 1-1. Open-Meteo API로 해당 위치의 Timezone 가져오기
      final tzUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&timezone=auto');
      final tzRes = await http.get(tzUrl);
      String timezoneString = 'Asia/Seoul';
      if (tzRes.statusCode == 200) {
        final tzJson = jsonDecode(tzRes.body);
        timezoneString = tzJson['timezone'] as String? ?? 'Asia/Seoul';
      }

      // 2. timezone 패키지를 사용하여 과거 썸머타임(DST) 적용된 실제 Timezone Offset 계산
      final location = tz.getLocation(timezoneString);
      final tzDate = tz.TZDateTime(
        location,
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final tzOffset = tzDate.timeZoneOffset.inMinutes / 60.0;

      final birthTimeStr = _timeUnknown
          ? 'Unknown'
          : '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      final birthTimeForCalc = _timeUnknown ? '12:00' : birthTimeStr;

      final chart = AstrologyService.calculateChart(
        birthDate: _selectedDate,
        birthTime: birthTimeForCalc,
        latitude: lat,
        longitude: lon,
        timezoneOffset: tzOffset,
      );

      final client = Client()
        ..name = _nameController.text.trim()
        ..birthDate = _selectedDate
        ..birthTime = birthTimeStr
        ..birthPlace = '${_countryController.text.trim()}/${_cityController.text.trim()}'
        ..latitude = lat
        ..longitude = lon
        ..timezoneOffset = tzOffset
        ..placements = chart['placements']!
        ..aspects = chart['aspects']!
        ..note = _noteController.text.trim();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.clients.put(client);
      });

      // 클라우드 (Google Sheets) 동기화 (백그라운드로 실행)
      GoogleSheetsService.upsertClient(client);

      if (mounted) {
        AppSnackBar.show(context, message: '내담자가 등록되었습니다.');
        Navigator.of(context).pop(true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: '등록 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일';
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내담자 신규 등록'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              _buildInputContainer(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '내담자 이름 (식별용)',
                    labelStyle: TextStyle(color: Themes.gold),
                    border: InputBorder.none,
                    icon: Icon(Icons.person_rounded, color: Themes.gold),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker Button
              _buildInputContainer(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Themes.gold),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '생년월일(양력)',
                              style: TextStyle(fontSize: 12, color: Themes.gold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildInputContainer(
                child: Column(
                  children: [
                    InkWell(
                      onTap: _timeUnknown ? null : () => _selectTime(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                color: _timeUnknown ? Colors.grey : Themes.gold),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('태어난 시간',
                                    style: TextStyle(fontSize: 12, color: Themes.gold)),
                                const SizedBox(height: 4),
                                Text(
                                  _timeUnknown ? 'Unknown' : timeStr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _timeUnknown ? Colors.grey : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Checkbox(
                          value: _timeUnknown,
                          onChanged: (v) => setState(() => _timeUnknown = v ?? false),
                          activeColor: Themes.gold,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Text('출생 시간 알 수 없음 (Unknown)',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location / Geo Coordinates Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '출생지 정보',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Themes.gold),
                  ),
                  TextButton.icon(
                    onPressed: _applySeoulDefaults,
                    icon: const Icon(Icons.location_city_rounded, size: 18, color: Themes.gold),
                    label: const Text('서울 기준 입력', style: TextStyle(color: Themes.gold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Birth Country & City Fields
              Row(
                children: [
                  Expanded(
                    child: _buildInputContainer(
                      child: TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: '태어난 나라 (예: 한국)',
                          labelStyle: TextStyle(color: Themes.gold, fontSize: 13),
                          border: InputBorder.none,
                          icon: Icon(Icons.public_rounded, color: Themes.gold, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return '입력 요망';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputContainer(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: '태어난 도시 (예: 서울)',
                          labelStyle: TextStyle(color: Themes.gold, fontSize: 13),
                          border: InputBorder.none,
                          icon: Icon(Icons.location_city_rounded, color: Themes.gold, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return '입력 요망';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Note Field
              const Text(
                '기타 메모',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '내담자의 성향, 과거 이력 등 참고 메모를 자유롭게 남겨주세요.',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isSaving 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Themes.midnightBlue, strokeWidth: 2)
                    )
                  : const Text(
                      '차트 생성 및 내담자 등록',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Themes.cardShadow(Theme.of(context).brightness == Brightness.dark)],
      ),
      child: child,
    );
  }
}
