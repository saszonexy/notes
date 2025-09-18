import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // sinkronkan textfield dengan state
          nameController.text = state.name;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Foto profile
                CircleAvatar(
                  radius: 50,
                  backgroundImage: state.photoPath != null
                      ? (kIsWeb
                          ? NetworkImage(state.photoPath!)
                          : FileImage(File(state.photoPath!)) as ImageProvider)
                      : const AssetImage("assets/images/default_avatar.png"),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ProfileCubit>()
                            .updateProfilePicture(fromCamera: false);
                      },
                      icon: const Icon(Icons.photo),
                      label: const Text("Galeri"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ProfileCubit>()
                            .updateProfilePicture(fromCamera: true);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Kamera"),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Input nama
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol simpan
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<ProfileCubit>()
                        .updateName(nameController.text);
                  },
                  child: const Text("Simpan"),
                ),

                const Spacer(),

                // Logout
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
