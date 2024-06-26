import 'package:http/http.dart' as http;

class SaucenaoHandler {
  final String apiKey;
  final int? outputType;
  final int? testMode;
  final List<int>? dbs;
  final int? numres;
  final int? dedupe;
  final int? hide;
  SaucenaoHandler(
      {required this.apiKey,
      this.outputType,
      this.testMode,
      this.dbs,
      this.numres,
      this.dedupe,
      this.hide});
  Future<http.Response> fetchResponse() async {
    var url = "https://saucenao.com/search.php?api_key=$apiKey";
    final outputType =
        (this.outputType == null) ? '' : '&output_type=${this.outputType}';
    final testMode =
        (this.testMode == null) ? '' : '&test_mode=${this.testMode}';
    var x = '';
    if (this.dbs == null) {
      x = '';
    } else {
      this.dbs!.forEach((element) {
        x = x + '&dbs[]=$element';
      });
    }
    final dbs = x;
    final numres = this.numres == null ? '' : '&numres=${this.numres}';
    final dedupe = this.dedupe == null ? '' : '&dedupe=${this.dedupe}';
    final hide = this.hide == null ? '' : '&hide=${this.hide}';
    url = url + '$outputType$testMode$dbs$numres$dedupe$hide';
    try {
      http.Response response = await http.get(Uri.parse(url));
      return response;
    } on Exception catch (e) {
      print(e);
      return Future.error(e);
    }
  }
}

class SauceNaoException implements Exception {}
