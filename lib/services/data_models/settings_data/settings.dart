class Settings {
  late bool lightMode;
  late bool dataSaver;

  Settings({required this.lightMode, required this.dataSaver});

  Settings.fromJson(Map<String, dynamic> json) {
    lightMode = json['lightMode'] ?? true;
    dataSaver = json['dataSaver'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lightMode'] = this.lightMode;
    data['dataSaver'] = this.dataSaver;
    return data;
  }
}
