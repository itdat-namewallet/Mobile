import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/providers/theme_provider.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:itdat/screen/mainLayout.dart';
import 'package:itdat/widget/login_screen/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/providers/locale_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocaleProvider, ThemeProvider, AuthProvider>(
      builder: (context, localeProvider, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'ITDAT',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''), // English
            Locale('ko', ''), // Korean
            Locale('ja', ''),
          ],
          home: FutureBuilder(
            future: authProvider.checkLoginStatus(), // 로그인 상태 확인
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 로그인 상태를 확인하는 동안 로딩 화면
                return Center(child: CircularProgressIndicator());
              } else {
                // 로그인 상태에 따라 다른 화면을 표시
                if (authProvider.isLoggedIn) {
                  return MainLayout(); // 로그인 성공 시
                } else {
                  return LoginScreen(); // 로그인 실패 시
                }
              }
            },
          ),
        );
      },
    );
  }
}