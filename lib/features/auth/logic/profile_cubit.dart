import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ImagePicker _picker = ImagePicker();

  ProfileCubit() : super(ProfileState.initial());

  void updateName(String newName) {
    emit(state.copyWith(name: newName));
  }

  Future<void> updateProfilePicture({required bool fromCamera}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        String path;

        if (kIsWeb) {
          // di web, file disimpan sebagai URL blob
          path = pickedFile.path;
        } else {
          // di mobile, simpan path lokal
          path = File(pickedFile.path).path;
        }

        emit(state.copyWith(photoPath: path));
      }
    } catch (e) {
      print("Gagal ambil foto: $e");
    }
  }
}
