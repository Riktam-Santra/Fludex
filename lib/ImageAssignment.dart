import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageManager {
  storeAndGetImage(String url, String fileName) async {
    var response = await http.get(Uri.parse(url));
    var documentsDirectory = await getApplicationSupportDirectory();
    var firstPath = documentsDirectory.path + "/images";
    if (await Directory(firstPath).exists() != true) {
      await Directory(firstPath).create(recursive: true);
    }
    if (await File(documentsDirectory.path + '/' + fileName).exists() != true) {
      File(fileName).create(recursive: true);
    }
    File file2 = File(fileName);
    file2.writeAsBytesSync(response.bodyBytes);
    return file2.path;
  }

  clean() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentsDirectory.path + '/images';
    if (await Directory(firstPath).exists()) {
      Directory(firstPath).delete(recursive: true);
    }
  }
}
