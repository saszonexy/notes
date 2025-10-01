class AppUser {
  final String uid;
  final String? email;

  var id;

  AppUser({required this.uid, this.email});

  factory AppUser.fromFirebaseUser(dynamic user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
    );
  }
}
