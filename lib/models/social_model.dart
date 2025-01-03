import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialsModel {
  final String baseUrl = 'http://10.0.2.2:8082'; // 김

  // Google 로그인
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final String googleUrl = '$baseUrl/api/oauth/google';
    print('Google API 호출 시작: $googleUrl');
    print('전송 데이터: $idToken');

    try {
      final response = await http.post(
        Uri.parse(googleUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'idToken': idToken}),
      );
      print('Google API 응답 상태 코드: ${response.statusCode}');
      print('Google API 응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        print('Google 로그인 실패: ${response.body}');
        return {'success': false, 'message': 'Google 로그인 실패: ${response.body}'};
      }
    } catch (e) {
      print('Google 로그인 오류: $e');
      return {'success': false, 'message': 'Google 로그인 실패: $e'};
    }
  }


  // Kakao OAuth 인증 코드 전달 및 처리
  Future<Map<String, dynamic>> handleKakaoAuthCode(String code) async {
    final String kakaoUrl = '$baseUrl/api/oauth/callback/kakao';
    print('Kakao Authorization Code 전달 시작: $kakaoUrl');
    print('전송 데이터: $code');

    try {
      final response = await http.post(
        Uri.parse(kakaoUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'code': code}),
      );

      print('Kakao 서버 응답 상태 코드: ${response.statusCode}');
      print('Kakao 서버 응답 데이터: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': 'Kakao 인증 처리 실패: ${response.body}',
        };
      }
    } catch (e) {
      print("Kakao 인증 처리 중 오류 발생: $e");
      return {'success': false, 'message': 'Kakao 인증 처리 중 오류'};
    }
  }

  // Kakao 로그인
  Future<Map<String, dynamic>> kakaoLogin(String accessToken) async {
    final String kakaoUrl = '$baseUrl/api/oauth/kakao';
    print('Kakao API 호출 시작: $kakaoUrl');
    print('kakao 전송 데이터: $accessToken');

    try {
      final response = await http.post(
        Uri.parse(kakaoUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Kakao API 응답 상태 코드: ${response.statusCode}');
      print('Kakao API 응답 데이터: ${response.body}');

      final responseBody = jsonDecode(response.body);

      print("Kakao 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': 'Kakao 로그인 실패: ${response.body}',
        };
      }
    } catch (e) {
      print("Kakao 로그인 오류: $e");
      return {'success': false, 'message': 'Kakao 로그인 실패'};
    }
  }

  Future<void> sendAuthorizationCode(String code) async {
    final client = http.Client();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/api/oauth/callback/kakao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception('Kakao 인증 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('HTTP 요청 실패: $e');
    } finally {
      client.close();
    }
  }

  // Naver 로그인
  // 네이버 로그인 URL 생성
  String getNaverAuthorizationUrl(String clientId, String redirectUri, String state) {
    return 'https://nid.naver.com/oauth2.0/authorize?response_type=code'
        '&client_id=$clientId'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&state=$state';
  }

  // 네이버 로그인 백엔드 호출
  Future<Map<String, dynamic>> naverLogin(String code, String state) async {
    final String naverUrl = '$baseUrl/api/oauth/callback/naver';
    print('Naver API 호출 시작: $naverUrl');
    print('naver 전송 데이터 - code: $code, state: $state');

    try {
      // GET 요청으로 백엔드의 네이버 콜백 엔드포인트 호출
      final Uri uri = Uri.parse('$naverUrl?code=$code&state=$state');
      final response = await http.get(uri);

      print('Naver API 응답 상태 코드: ${response.statusCode}');
      print('Naver API 응답 데이터: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': 'Naver 로그인 실패: ${response.body}',
        };
      }
    } catch (e) {
      print("Naver 로그인 오류: $e");
      return {'success': false, 'message': 'Naver 로그인 실패'};
    }
  }

  Future<void> sendCodeAndState(String code, String state) async {
    final String backendUrl = '$baseUrl/api/oauth/callback/naver?code=$code&state=$state';

    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        print('서버 응답 성공: ${response.body}');
      } else {
        print('서버 응답 실패: ${response.body}');
      }
    } catch (e) {
      print('서버 요청 실패: $e');
    }
  }

  // 백엔드에서 로그인 결과 가져오기 (추가적인 별도 호출용)
  Future<Map<String, dynamic>> fetchBackendLoginResult() async {
    final String backendUrl = '$baseUrl/api/oauth/callback/naver';
    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('백엔드 로그인 결과 요청 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('백엔드 호출 실패: $e');
    }
  }
}
