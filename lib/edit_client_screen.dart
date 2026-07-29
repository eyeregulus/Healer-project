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

  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  late final TextEditingController _dayController;
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;

  late final FocusNode _yearFocusNode;
  late final FocusNode _monthFocusNode;
  late final FocusNode _dayFocusNode;
  late final FocusNode _hourFocusNode;
  late final FocusNode _minuteFocusNode;

  bool _timeUnknown = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _yearFocusNode = FocusNode();
    _monthFocusNode = FocusNode();
    _dayFocusNode = FocusNode();
    _hourFocusNode = FocusNode();
    _minuteFocusNode = FocusNode();

    final c = widget.client;
    _nameController = TextEditingController(text: c.name);
    _noteController = TextEditingController(text: c.note);

    final placeParts = c.birthPlace.split('/');
    _countryController = TextEditingController(
        text: placeParts.isNotEmpty ? placeParts[0] : '');
    _cityController = TextEditingController(
        text: placeParts.length > 1 ? placeParts[1] : '');

    _yearController = TextEditingController(text: c.birthDate.year.toString());
    _monthController = TextEditingController(text: c.birthDate.month.toString());
    _dayController = TextEditingController(text: c.birthDate.day.toString());

    if (c.birthTime == 'Unknown' || c.birthTime == '00:00') {
      _timeUnknown = true;
      _hourController = TextEditingController();
      _minuteController = TextEditingController();
    } else {
      final parts = c.birthTime.split(':');
      _hourController = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
      _minuteController = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _yearFocusNode.dispose();
    _monthFocusNode.dispose();
    _dayFocusNode.dispose();
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final year = int.tryParse(_yearController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final day = int.tryParse(_dayController.text.trim());

    if (year == null || month == null || day == null) {
      AppSnackBar.show(context, message: '생년월일을 올바르게 입력해 주세요.');
      return;
    }

    DateTime birthDate;
    try {
      birthDate = DateTime(year, month, day);
    } catch (_) {
      AppSnackBar.show(context, message: '유효한 날짜가 아닙니다.');
      return;
    }

    int hour = 12;
    int minute = 0;
    if (!_timeUnknown) {
      final h = int.tryParse(_hourController.text.trim());
      final m = int.tryParse(_minuteController.text.trim());
      if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
        AppSnackBar.show(context, message: '태어난 시간을 올바르게 입력해 주세요 (0~23시, 0~59분).');
        return;
      }
      hour = h;
      minute = m;
    }

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
      final tzDate = tz.TZDateTime(location, birthDate.year,
          birthDate.month, birthDate.day,
          hour, minute);
      final tzOffset = tzDate.timeZoneOffset.inMinutes / 60.0;

      final birthTimeStr = _timeUnknown
          ? 'Unknown'
          : '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      final chart = AstrologyService.calculateChart(
        birthDate: birthDate,
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
          ..birthDate = birthDate
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
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _yearFocusNode.requestFocus(),
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
              const SizedBox(height: 20),

              // 생년월일 (직접 입력)
              const Text(
                '생년월일 (양력)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildCard(
                      child: TextFormField(
                        controller: _yearController,
                        focusNode: _yearFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'YYYY',
                          labelText: '년',
                          labelStyle: TextStyle(color: Themes.gold),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 4) {
                            _monthFocusNode.requestFocus();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return '필수';
                          final y = int.tryParse(value);
                          if (y == null || y < 1900 || y > 2100) return '범위 오류';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCard(
                      child: TextFormField(
                        controller: _monthController,
                        focusNode: _monthFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'MM',
                          labelText: '월',
                          labelStyle: TextStyle(color: Themes.gold),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 2) {
                            _dayFocusNode.requestFocus();
                          } else if (value.length == 1) {
                            final val = int.tryParse(value);
                            if (val != null && val >= 2 && val <= 9) {
                              _dayFocusNode.requestFocus();
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return '필수';
                          final m = int.tryParse(value);
                          if (m == null || m < 1 || m > 12) return '오류';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCard(
                      child: TextFormField(
                        controller: _dayController,
                        focusNode: _dayFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'DD',
                          labelText: '일',
                          labelStyle: TextStyle(color: Themes.gold),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 2) {
                            if (_timeUnknown) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              _hourFocusNode.requestFocus();
                            }
                          } else if (value.length == 1) {
                            final val = int.tryParse(value);
                            if (val != null && val >= 4 && val <= 9) {
                              if (_timeUnknown) {
                                FocusScope.of(context).nextFocus();
                              } else {
                                _hourFocusNode.requestFocus();
                              }
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return '필수';
                          final d = int.tryParse(value);
                          if (d == null || d < 1 || d > 31) return '오류';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 태어난 시간 (직접 입력)
              const Text(
                '태어난 시간 (24시간제)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      child: TextFormField(
                        controller: _hourController,
                        focusNode: _hourFocusNode,
                        enabled: !_timeUnknown,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '시 (0-23)',
                          labelText: '시',
                          labelStyle: TextStyle(color: Themes.gold),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 2) {
                            _minuteFocusNode.requestFocus();
                          } else if (value.length == 1) {
                            final val = int.tryParse(value);
                            if (val != null && val >= 3 && val <= 9) {
                              _minuteFocusNode.requestFocus();
                            }
                          }
                        },
                        validator: (value) {
                          if (_timeUnknown) return null;
                          if (value == null || value.trim().isEmpty) return '필수';
                          final h = int.tryParse(value);
                          if (h == null || h < 0 || h > 23) return '오류';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCard(
                      child: TextFormField(
                        controller: _minuteController,
                        focusNode: _minuteFocusNode,
                        enabled: !_timeUnknown,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '분 (0-59)',
                          labelText: '분',
                          labelStyle: TextStyle(color: Themes.gold),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 2) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.length == 1) {
                            final val = int.tryParse(value);
                            if (val != null && val >= 6 && val <= 9) {
                              FocusScope.of(context).nextFocus();
                            }
                          }
                        },
                        validator: (value) {
                          if (_timeUnknown) return null;
                          if (value == null || value.trim().isEmpty) return '필수';
                          final m = int.tryParse(value);
                          if (m == null || m < 0 || m > 59) return '오류';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Checkbox(
                    value: _timeUnknown,
                    onChanged: (v) {
                      setState(() {
                        _timeUnknown = v ?? false;
                        if (_timeUnknown) {
                          _hourController.clear();
                          _minuteController.clear();
                        }
                      });
                    },
                    activeColor: Themes.gold,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text('출생 시간 알 수 없음 (Unknown)',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),

              // 출생지
              const Text(
                '출생지 정보',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Themes.gold),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 24),

              // 메모
              const Text('기타 메모',
                  style: TextStyle(
                      fontSize: 15,
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
