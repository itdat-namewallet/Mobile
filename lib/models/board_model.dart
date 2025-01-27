import 'dart:convert';
import 'dart:io';
import 'package:itdat/utils/HttpClientManager.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BoardModel{
  final baseUrl = "${dotenv.env['BASE_URL']}/board/portfolio";
  final historyBaseUrl = "${dotenv.env['BASE_URL']}/board/history";


  // 가져오기
  Future<List<Map<String,dynamic>>> getPosts(String userEmail) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$baseUrl/$userEmail"));
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      throw Exception("getPosts Error: $e");
    }
  }


  // 저장
  Future<void> savePost(Map<String, dynamic> postData) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final url = Uri.parse("$baseUrl/save");
      var request = http.MultipartRequest('POST', url);

      request.fields['postData'] = json.encode(postData).trim();

      if (postData['fileUrl'] != null && postData['fileUrl']!.isNotEmpty) {
        final file = File(postData['fileUrl']);
        if (file.existsSync()) {
          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          final fileName = path.basename(file.path);

          request.files.add(
            http.MultipartFile(
              'file',
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      if (postData['documentUrl'] != null && postData['documentUrl']!.isNotEmpty) {
        final document = File(postData['documentUrl']);
        if (document.existsSync()) {
          final mimeType = lookupMimeType(document.path) ?? 'application/octet-stream';
          final fileName = path.basename(document.path);

          request.files.add(
            http.MultipartFile(
              'document',
              document.readAsBytes().asStream(),
              document.lengthSync(),
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception("Failed to save post. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("savePost Error: $e");
    }
  }



  // 수정
  Future<void> editPost(Map<String, dynamic> postData, int postId) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final url = Uri.parse("$baseUrl/edit/$postId");
      var request = http.MultipartRequest('PUT', url);

      request.fields['postData'] = json.encode(postData).trim();

      if (postData['fileUrl'] != null && postData['fileUrl']!.isNotEmpty) {
        final file = File(postData['fileUrl']);
        if (file.existsSync()) {
          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          final fileName = path.basename(file.path);

          request.files.add(
            http.MultipartFile(
              'file',
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      if (postData['documentUrl'] != null && postData['documentUrl']!.isNotEmpty) {
        final document = File(postData['documentUrl']);
        if (document.existsSync()) {
          final mimeType = lookupMimeType(document.path) ?? 'application/octet-stream';
          final fileName = path.basename(document.path);

          request.files.add(
            http.MultipartFile(
              'document',
              document.readAsBytes().asStream(),
              document.lengthSync(),
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception("Failed to edit post. Status code: ${response.statusCode}");
      }

    } catch (e) {
      throw Exception("savePost Error: $e");
    }
  }



  // 삭제
  Future<void> deletePost(int postId) async {
    final client = await HttpClientManager().createHttpClient();

    try{
      await client.delete(Uri.parse("$baseUrl/delete/$postId"));
    } catch (e) {
      throw Exception("deletePost Error: $e");
    }
  }




  Future<List<Map<String,dynamic>>> getHistories(String userEmail) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.get(Uri.parse("$historyBaseUrl/$userEmail"));
      return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      throw Exception("getHistories Error: $e");
    }
  }



  Future<void> saveHistory(Map<String, dynamic> postData) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      await client.post(
        Uri.parse('$historyBaseUrl/save'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(postData).trim()
      );

    } catch (e) {
      throw Exception("saveHistoryPost Error: $e");
    }
  }


  Future<void> editHistory(Map<String, dynamic> postData, int postId) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      await client.put(
          Uri.parse("$historyBaseUrl/edit/$postId"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(postData).trim()
      );
    } catch (e) {
      throw Exception("editHistoryPost Error: $e");
    }
  }


  Future<void> deleteHistory(int postId) async {
    final client = await HttpClientManager().createHttpClient();

    try{
      await client.delete(Uri.parse("$historyBaseUrl/delete/$postId"));
    } catch (e) {
      throw Exception("deleteHistory Error: $e");
    }
  }
}
