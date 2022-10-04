class LoginData {
  final String session;
  final String refresh;
  final int timestamp;
  LoginData(this.session, this.refresh, this.timestamp);
  LoginData.fromJson(Map<String, dynamic> json)
      : session = json['session'],
        refresh = json['refresh'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
        'session': session,
        'refresh': refresh,
        'timestamp': timestamp,
      };
}
