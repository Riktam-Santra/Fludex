class LoginData {
  final String username;
  final String password;
  final String session;
  final String refresh;
  LoginData(this.username, this.password, this.session, this.refresh);
  LoginData.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        password = json['password'],
        session = json['session'],
        refresh = json['refresh'];

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'session': session,
        'refresh': refresh,
      };
}
