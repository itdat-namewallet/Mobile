import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../utils/HttpClientManager.dart';

class EmailVerificationService {
  final String sendEmailUrl = "http://10.0.2.2:8082/api/email/send";
  final String verifyEmailUrl = "http://10.0.2.2:8082/api/email/verify";

  final baseUrl = dotenv.env['BASE_URL'];

  // 이메일 인증 코드 발송
  Future<bool> sendVerificationCode(String email) async {
    final client = await HttpClientManager().createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print(sendEmailUrl);
        print("서버 응답 상태 코드: ${response.statusCode}");
        print("서버 응답 메시지: ${response.body}");
        return false;
      }
    } catch (e) {
      print("이메일 발송 실패: $e");
      return false;
    }
  }

  // 이메일 인증 코드 검증
  //test
  Future<bool> verifyCode(String email, String code) async {
    final client = await HttpClientManager().createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/email/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("이메일 인증 실패: $e");
      return false;
    }
  }
}
