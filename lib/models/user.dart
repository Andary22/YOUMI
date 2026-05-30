class AppUser {
  final String id;
  final String email;
  final String themePref;
  final String name;

  const AppUser({
    required this.id,
    required this.email,
    required this.themePref,
    this.name = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final String? rawName = json['name'] as String?;
    String parsedName;
    if (rawName == null) {
      parsedName = '';
    } else {
      parsedName = rawName;
    }
    if (parsedName == '"' || parsedName == "'") {
      parsedName = '';
    }
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      themePref: json['theme_pref'] as String,
      name: parsedName,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'theme_pref': themePref, 'name': name};
  }

  Map<String, dynamic> toJsonCreate() {
    return {'id': id, 'email': email, 'theme_pref': themePref};
  }
}