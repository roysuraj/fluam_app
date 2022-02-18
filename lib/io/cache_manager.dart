import 'dart:io';

import 'package:fluam_app/util/StringUtil.dart';
import 'package:hive/hive.dart';

class AppCacheManager {
  static const String dbName = "cache_manager";
  static late String _cachePath;
  static late int _maxCacheCount;
  static late HttpClient _httpClient;

  static Map<String, Future<File>> loadingMap = {};

  static Future<void> init(String cachePath, int maxCacheCount) async {
    _cachePath = cachePath;
    final dir =  Directory(cachePath);
    if (! await dir.exists()) {
      dir.create(recursive: true);
    }
    _maxCacheCount = maxCacheCount;
    _httpClient = HttpClient();
    await _checkDB();
  }

  static Future _checkDB() async {
    final box = await Hive.openBox(dbName);
    box.keys.forEach((name) async {
      if (!await File("$_cachePath/$name").exists()) {
        await box.delete(name);
        print("delete lost cache DB:$name");
      }
    });
  }

  static Future<File>? getFile(String url) async {
    final String fileName = getFileName(url);
    final File file = File(_cachePath + "/$fileName");

    if (loadingMap.keys.contains(fileName)) {
      return loadingMap[fileName]!;
    }

    /// if File exists,return file
    if (await file.exists()) {
      if (await _dbHasFile(fileName)) {
        return file;
      }

      /// if File not in db,delete
      await file.delete();
    }

    /// else Download File

    if (await getCacheListLen() > _maxCacheCount) {
      await removeLastFile();
    }
    print("add Cache:$fileName");
    loadingMap.addAll({fileName: _getFileWithUrl(file, url, fileName)});
    return loadingMap[fileName]!;
  }

  static Future<File> _getFileWithUrl(
      File file, String url, String fileName) async {
    final req = await _httpClient.getUrl(Uri.parse(url));
    req.headers.add("User-Agent",
        "Fluam/cache_manager A cross-platform flarum client. (github.com/fluam/fluam_app)");
    final result = await req.close();
    file.create(recursive: true);
    final w = file.openWrite();
    await w.addStream(result);
    w.flush();
    await w.close();
    await _addFileInDB(fileName);
    loadingMap.remove(fileName);
    return file;
  }

  static Future<bool> _addFileInDB(String fileName) async {
    final box = await Hive.openBox(dbName);
    await box.put(fileName, DateTime.now().millisecondsSinceEpoch);
    return true;
  }

  static Future<bool> _dbHasFile(String fileName) async {
    final box = await Hive.openBox(dbName);
    return box.keys.contains(fileName);
  }

  static Future<bool> removeLastFile() async {
    final box = await Hive.openBox(dbName);
    final String fileName = box.keys.first;
    return removeFile(fileName);
  }

  static Future<bool> removeFile(String fileName) async {
    final box = await Hive.openBox(dbName);
    final file = File(fileName);
    if (await file.exists()) {
      await file.delete();
    }
    await box.delete(fileName);
    return true;
  }

  static Future<int> getCacheListLen() async {
    final box = await Hive.openBox(dbName);
    return box.length;
  }

  static String getFileName(String url) {
    return StringUtil.getSha1(url);
  }
}
