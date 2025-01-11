import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserModel {
  final storage = FlutterSecureStorage();
  // final String baseUrl = "http://112.221.66.174:8000";
  final String baseUrl = "http://112.221.66.174:8001";

  Future<Map<String, dynamic>> getUserInfo() async {
    String? email = await storage.read(key: 'email');
    print('email: $email');
    if (email == null) {
      throw Exception('email not found');
    }

    final response = await http.post(
        Uri.parse('$baseUrl/nfc/userinfo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email})
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<bool> updateUserInfo(Map<String, dynamic> map) async {
    String? email = await storage.read(key: 'email');
    if (email == null) {
      throw Exception('email not found');
    }
    map['email'] = email;
    print('Sending request to: $baseUrl/nfc/updateuser');
    print('Request body!!: ${jsonEncode(map)}');

    final response = await http.post(
        Uri.parse('$baseUrl/nfc/updateuser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map)
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update user info');
    }
  }

  Future<bool> verifyPassword(String password, String email) async {
    final String url = '$baseUrl/nfc/password';

    try {
      final Map<String, dynamic> requestBody = {
        'password': password,
        'email': email
      };
      print(password);

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['isValid'] ?? false;
      } else {
        print("서버 오류: 상태 코드 ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return false;
    }
  }
  Future<bool> changePassword(String newPassword) async {
    String? email = await storage.read(key: 'email');
    print("오긴하나");
    print(newPassword);
    if (email == null) {
      throw Exception('email not found');
    }
    final String url = '$baseUrl/nfc/passwordchange';

    try {
      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': newPassword
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("서버 오류: 상태 코드 ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return false;
    }
  }

  Future<bool> deleteAccount(String userEmail) async {
    final String url = '$baseUrl/nfc/deleteaccount';
    try {
      final Map<String, dynamic> requestBody = {
        'email': userEmail,
      };
      String? authToken = await storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken', // 인증 토큰 추가
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        // 계정 삭제 성공
        await storage.deleteAll(); // 로컬 저장소의 모든 데이터 삭제
        return true;
      } else {
        print("탈퇴서버 오류: 상태 코드 ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return false;
    }
  }

}