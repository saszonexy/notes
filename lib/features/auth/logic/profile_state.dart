import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String name;
  final String? photoPath;

  const ProfileState({
    required this.name,
    this.photoPath,
  });

  factory ProfileState.initial() {
    return const ProfileState(name: "", photoPath: null);
  }

  ProfileState copyWith({
    String? name,
    String? photoPath,
  }) {
    return ProfileState(
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => [name, photoPath];
}
