class LoginData {
  final String session;
  final String refresh;
  LoginData(this.session, this.refresh);
  LoginData.fromJson(Map<String, dynamic> json)
      : session = json['session'],
        refresh = json['refresh'];

  Map<String, dynamic> toJson() => {
        'session': session,
        'refresh': refresh,
      };
}
