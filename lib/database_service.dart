import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/client.dart';
import 'models/consultation.dart';
import 'models/preference.dart';

class DatabaseService {
  static late Isar isar;
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Open Isar database with all schemas and write default preferences if missing.
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    
    isar = await Isar.open(
      [ClientSchema, ConsultationSchema, PreferenceSchema],
      directory: dir.path,
    );

    _initialized = true;

    // Insert default preferences if none exist or update old OpenAI defaults to Gemini
    final pref = await isar.preferences.get(0);
    if (pref == null) {
      final defaultPref = Preference();
      await isar.writeTxn(() async {
        await isar.preferences.put(defaultPref);
      });
    } else if (pref.customEndpoint.contains('openai.com')) {
      pref.customEndpoint = 'https://generativelanguage.googleapis.com';
      pref.apiKey = '';
      pref.modelName = 'gemini-1.5-flash-8b';
      await isar.writeTxn(() async {
        await isar.preferences.put(pref);
      });
    }
  }
}
