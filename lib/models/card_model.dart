import 'package:dio/dio.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CardModel{

  //final baseUrl = "http://112.221.66.174:8001/card";  // 원
  final baseUrl = "http://112.221.66.174:8000/card"; //정원
  final dio = Dio();


  // 유저 정보 가져오기
  Future<Map<String, dynamic>> getUserById(String userEmail) async {

    try{
      final response = await http.get(Uri.parse("$baseUrl/userinfo/$userEmail"));

      if(response.statusCode == 200){
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('회원 정보 가져오기 실패: ${response.statusCode}');
      }
    }catch(e){
      print("회원 정보 가져오기 실패");
      throw Exception("getUserById Error: $e");
    }
  }



  // 명함 저장
  Future<BusinessCard> createBusinessCard(BusinessCard card) async {
    try{
        final response = await http.post(
          Uri.parse('$baseUrl/save'),
          headers: {"Content-Type": "application/json; charset=UTF-8" },
          body: json.encode(card.toJson()),
        );


        if(response.statusCode == 200){
          return BusinessCard.fromJson(json.decode(response.body));
        }else{
          throw Exception('명함 저장 실패: ${response.statusCode}');
        }
    }catch(e){
      print("명함 생성 실패 $e");
      throw Exception("createBusinessCard Error: $e");
    }
  }


  // 명함 가져오기
  Future<List<dynamic>> getBusinessCard(String userEmail) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userEmail"));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('명함 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('getBusinessCard Error: $e');
    }
  }
}


