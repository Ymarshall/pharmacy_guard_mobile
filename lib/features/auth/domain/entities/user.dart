class User {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String? name;
  final String? photoUrl;
  final AuthProvider authProvider;

  const User({
    required this.id,
    this.phoneNumber,
    this.email,
    this.name,
    this.photoUrl,
    required this.authProvider,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum AuthProvider {
  phone,
  google,
  facebook,
}

