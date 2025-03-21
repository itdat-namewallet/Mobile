import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/utils/HttpClientManager.dart';


class MyWalletModel {
  final baseUrl = dotenv.env['BASE_URL'];

  // 명함 가져오기
  Future<List<dynamic>> getCards(String myEmail) async {
    final client = await HttpClientManager().createHttpClient();

    final url = '$baseUrl/api/mywallet/cards?myEmail=$myEmail';
    try {
      final response = await client.get(Uri.parse(url));
      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch cards');
      }
    } catch (e) {
      print('API 호출 중 오류: $e');
      rethrow;
    }
  }

  // 폴더 가져오기
  Future<List<dynamic>> getFolders(String userEmail) async {
    final client = await HttpClientManager().createHttpClient();

    final url = '$baseUrl/api/mywallet/folders?userEmail=$userEmail';
    try {
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch folders');
      }
    } catch (e) {
      print('폴더 API 호출 중 오류: $e');
      rethrow;
    }
  }

  // 폴더 내부 명함 가져오기
  Future<List<dynamic>> getFolderCards(String folderName) async {
    final client = await HttpClientManager().createHttpClient();

    final url = '$baseUrl/api/mywallet/folderCards?folderName=$folderName';
    try {
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch folder cards');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 폴더 생성
  Future<bool> createFolder(String userEmail, String folderName) async {
    final client = await HttpClientManager().createHttpClient();

    final response = await client.post(
      Uri.parse("$baseUrl/api/mywallet/folders/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userEmail": userEmail, "folderName": folderName}),
    );
    return response.statusCode == 200;
  }

  // 폴더 이름 업데이트
  Future<bool> updateFolderName(String userEmail, String oldFolderName, String newFolderName) async {
    final client = await HttpClientManager().createHttpClient();

    final response = await client.put(
      Uri.parse("$baseUrl/api/mywallet/folders/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userEmail": userEmail,
        "oldFolderName": oldFolderName,
        "newFolderName": newFolderName
      }),
    );

    if (response.statusCode == 200) {
      print("폴더 이름 업데이트 성공");
      return true;
    } else {
      print("폴더 이름 업데이트 실패: ${response.statusCode}");
      return false;
    }
  }

  // 폴더 삭제
  Future<bool> deleteFolder(String userEmail, String folderName) async {
    final client = await HttpClientManager().createHttpClient();

    final response = await client.delete(
      Uri.parse("$baseUrl/api/mywallet/folders/$folderName?userEmail=$userEmail"),
    );
    return response.statusCode == 200;
  }

  // 명함 폴더로 이동
  Future<bool> moveCardToFolder(String myEmail, String userEmail, String folderName) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.post(
        Uri.parse("$baseUrl/api/mywallet/moveCard"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "myEmail": myEmail,
          "userEmail": userEmail,
          "folderName": folderName.isEmpty ? null : folderName, // 폴더 이름 처리
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("API 호출 실패: ${response.body}");
        debugPrint("API 엔드포인트: $baseUrl/moveCard");
        return false;
      }
    } catch (e) {
      debugPrint("API 호출 중 오류: $e");
      return false;
    }
  }

  Future<Map<String, String>> getUserInfoByEmail(String email) async {
    final client = await HttpClientManager().createHttpClient();

    final response = await client.get(
      Uri.parse('$baseUrl/api/auth/info?email=$email'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user info');
    }
  }

  Future<List<dynamic>> getAllCards(String userEmail) async {
    final client = await HttpClientManager().createHttpClient();

    final url = '$baseUrl/api/mywallet/allCards?userEmail=$userEmail';
    final response = await client.get(Uri.parse(url));
      print("1: ${response.statusCode}");
      print("1 :${jsonDecode(response.body)}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("2: ${response.statusCode}");
      throw Exception("Failed to fetch business cards");
    }
  }

  // 폴더에 속하지 않은 명함 가져오기
  Future<List<dynamic>> getCardsWithoutFolder(String myEmail) async {
    final client = await HttpClientManager().createHttpClient();

    final response = await client.get(
      Uri.parse("$baseUrl/api/mywallet/cards/withoutFolder?myEmail=$myEmail"),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load cards without folder");
    }
  }

  // 특정 폴더의 명함 가져오기
  Future<List<dynamic>> getCardsByFolder(String myEmail, String folderName) async {
    final client = await HttpClientManager().createHttpClient();

    final response = await client.get(
      Uri.parse("$baseUrl/api/mywallet/cards/byFolder?myEmail=$myEmail&folderName=$folderName"),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load cards by folder");
    }
  }
}
