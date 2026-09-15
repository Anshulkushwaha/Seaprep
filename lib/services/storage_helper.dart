import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart';

class StorageHelper {
  static String? getItem(String key) => getWebItem(key);
  static void setItem(String key, String value) => setWebItem(key, value);
}
