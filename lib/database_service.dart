import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/client.dart';
import 'models/consultation.dart';
import 'models/preference.dart';

class DatabaseService {
  static late Isar isar;

  /// Open Isar database with all schemas and write default preferences if missing.
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    
    isar = await Isar.open(
      [ClientSchema, ConsultationSchema, PreferenceSchema],
      directory: dir.path,
    );

    // Insert default preferences if none exist
    final count = await isar.preferences.count();
    if (count == 0) {
      final defaultPref = Preference();
      await isar.writeTxn(() async {
        await isar.preferences.put(defaultPref);
      });
    }
  }
}
