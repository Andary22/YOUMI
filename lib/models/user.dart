class AppUser {
  final String id;
  final String email;
  final String themePref;

  const AppUser({
    required this.id,
    required this.email,
    required this.themePref,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      themePref: json['theme_pref'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'theme_pref': themePref};
  }
}
