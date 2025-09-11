import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api";
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000/api";
    } else {
      return "http://192.168.1.10:8000/api";
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<http.Response> register(
      String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Login response: $data");

      String? token;

      if (data['token'] != null) {
        token = data['token'];
      } else if (data['access_token'] != null) {
        token = data['access_token'];
      } else if (data['authorisation'] != null &&
          data['authorisation']['token'] != null) {
        token = data['authorisation']['token'];
      }

      if (token != null) {
        await saveToken(token);
      } else {
        print("Token tidak ditemukan di response");
        throw Exception("Token tidak ditemukan di response");
      }
    } else {
      print("Login gagal: ${response.body}");
    }

    return response;
  }

  static Future<http.Response> getNotes() async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/notes");
    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  static Future<http.Response> createNote(String title, String content) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/notes");
    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );
  }

  static Future<http.Response> updateNote(
      int id, String title, String content) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/notes/$id");
    return await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );
  }

  static Future<http.Response> deleteNote(int id) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/notes/$id");
    return await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  static Future<http.Response> getUserInfo() async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/me");
    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  static Future<http.Response> uploadProfilePhotoWeb(
      Uint8List bytes, String filename) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/update-photo");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes('photo', bytes, filename: filename),
    );

    final response = await request.send();
    return http.Response.fromStream(response);
  }


  static Future<http.Response> uploadProfilePhoto(String filePath) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/update-photo");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    final response = await request.send();
    return http.Response.fromStream(response);
  }
}
