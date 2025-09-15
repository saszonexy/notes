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
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          name = data['name'];
          email = data['email'];
          photoUrl = data['profile_photo'] != null
              ? "${ApiService.baseUrl.replaceAll('/api', '')}/storage/${data['profile_photo']}"
              : null;
          loading = false;
        });
      } else {
        debugPrint("Gagal ambil data user: ${response.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
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
              ? "${ApiService.baseUrl.replaceAll('/api', '')}/storage/${data['photo_url']}"
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

  Future<void> updateUserName() async {
    final controller = TextEditingController(text: name ?? "");
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFDF7),
        title:
            const Text("Ubah Nama", style: TextStyle(color: Color(0xFF8B4513))),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Masukkan nama baru",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B4513)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Batal", style: TextStyle(color: Color(0xFFA0522D))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513)),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final response = await ApiService.updateName(newName);
      if (response.statusCode == 200) {
        setState(() => name = newName);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama berhasil diupdate")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update nama: ${response.body}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/notes'),
        ),
        title: const Text("Profil Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B4513),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E6D3), Color(0xFFE8D5B7)],
          ),
        ),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B4513)))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF7),
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: const Color(0xFFD4B896), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFF5E6D3),
                          child: photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person,
                                          size: 60, color: Color(0xFF8B4513));
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const CircularProgressIndicator(
                                          color: Color(0xFF8B4513));
                                    },
                                  ),
                                )
                              : const Icon(Icons.person,
                                  size: 60, color: Color(0xFF8B4513)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name ?? "Nama tidak tersedia",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 18, color: Color(0xFF8B4513)),
                              onPressed: updateUserName,
                            ),
                          ],
                        ),
                        Text(
                          email ?? "Email tidak tersedia",
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFFA0522D)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: pickAndUploadPhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Ganti Foto Profil"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
