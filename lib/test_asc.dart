import 'astrology_service.dart';

void main() async {
  try {
    await AstrologyService.init();
    final data = AstrologyService.calculateNatalData(
      birthDate: DateTime(1996, 8, 12),
      birthTime: '04:49',
      latitude: 37.5666791,
      longitude: 126.9782914,
      timezoneOffset: 9.0,
    );
    final asc = data['longitudes']['Ascendant'];
    final signIdx = (asc % 360 / 30).floor();
    final sign = AstrologyService.getZodiacSign(asc);
    print('Ascendant: \$asc (\${sign})');
  } catch (e) {
    print(e);
  }
}
