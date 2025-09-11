import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? email;
  String? photoUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await ApiService.getUserInfo();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'];
          email = data['email'];
          photoUrl = data['profile_photo'] != null
              ? ApiService.baseUrl.replaceAll('/api', '') +
                  "/storage/${data['profile_photo']}"
              : null;
          loading = false;
        });
      } else {
        debugPrint("Gagal ambil data user: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> pickAndUploadPhoto() async {
    try {
      http.Response response;

      if (kIsWeb) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) throw Exception("Tidak ada file yang dipilih");

        final bytes = await pickedFile.readAsBytes();
        response =
            await ApiService.uploadProfilePhotoWeb(bytes, pickedFile.name);
      } else {
        response = await _pickAndUploadMobile();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          photoUrl = data['photo_url'] != null
              ? ApiService.baseUrl.replaceAll('/api', '') +
                  "/storage/${data['photo_url']}"
              : null;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diupload")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload gagal: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload gagal: $e")),
      );
    }
  }

  Future<http.Response> _pickAndUploadMobile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) throw Exception("Tidak ada file yang dipilih");
    return await ApiService.uploadProfilePhoto(pickedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl!)
                        : const AssetImage("assets/default_avatar.png")
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name ?? "Nama tidak tersedia",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(email ?? "Email tidak tersedia"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: pickAndUploadPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Ganti Foto Profil"),
                  ),
                ],
              ),
            ),
    );
  }
}
