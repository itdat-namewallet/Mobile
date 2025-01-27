import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:itdat/models/login_model.dart';
import 'package:itdat/screen/splash_widget.dart';
import 'package:itdat/utils/MyHttpOverrieds.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:itdat/widget/register/register_screen.dart';
import 'package:itdat/providers/theme_provider.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:itdat/providers/locale_provider.dart';
import 'package:itdat/providers/font_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final nativeAppKey = dotenv.env['NATIVE_APP_KEY'];
  final javaScriptAppKey = dotenv.env['JAVASCRIPT_APP_KEY'];
  if (nativeAppKey == null || javaScriptAppKey == null) {
    throw Exception('NATIVE_APP_KEY 또는 JAVASCRIPT_APP_KEY가 설정되지 않았습니다.');
  }

  KakaoSdk.init(
    nativeAppKey: nativeAppKey,
    javaScriptAppKey: javaScriptAppKey,
    loggingEnabled: true,
  );


  // HttpOverrides 전역 설정
  HttpOverrides.global = MyHttpOverrides();  // 인증서 검증 적용

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => LoginModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _checkLoginStatus();
    _handleIncomingLinks();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isLoggedIn = await authProvider.checkLoginStatus();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  void _handleIncomingLinks() {
    // 기존 URI 처리 코드
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const MaterialApp(
    //     home: Scaffold(
    //       body: Center(child: WaitAnimationWidget()),
    //     ),
    //   );
    // }

    return Consumer4<LocaleProvider, ThemeProvider, AuthProvider, FontProvider>(
      builder: (context, localeProvider, themeProvider, authProvider, fontProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'ITDAT',
          theme: themeProvider.lightTheme.copyWith(
            textTheme: fontProvider.currentTextTheme,
          ),
          darkTheme: themeProvider.darkTheme.copyWith(
            textTheme: fontProvider.currentTextTheme,
          ),
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ko', ''),
            Locale('ja', ''),
          ],
          home: SplashScreen(isLoggedIn: _isLoggedIn),
          onGenerateRoute: (settings) {
            if (settings.name == '/register') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => RegisterScreen(
                  registrationData: args?.map((key, value) => MapEntry(key, value.toString())),
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}