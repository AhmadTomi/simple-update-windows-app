import 'dart:io';
class FileHelper {

  late final File _file;

  String get path => _file.path;

  FileHelper(String pathFiles){
    _file = File(pathFiles);
  }
  Future<File> write(String content) async {
    final file = _file;
    return file.writeAsString(content);
  }

  Future<String> read() async {
    try {
      final file = _file;
      String content = await file.readAsString();
      return content;
    } catch (e) {
      return '';
    }
  }

  Future<List<String>> readToList() async {
    String content = await read();
    return content.split('\n');
  }
}
