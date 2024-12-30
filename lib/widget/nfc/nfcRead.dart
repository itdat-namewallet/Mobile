import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class NfcReadPage extends StatefulWidget {
  @override
  _NfcReadPageState createState() => _NfcReadPageState();
}

class _NfcReadPageState extends State<NfcReadPage> {
  bool _isReading = false;
  bool _isRetryVisible = false;
  Timer? _vibrationTimer;
  String _baseText = 'NFC 태그를\n가까이 가져다 주세요';
  String _dots = '';
  Timer? _textAnimationTimer;

  @override
  void initState() {
    super.initState();
    _startNfcRead();
    _startTextAnimation();
  }

  @override
  void dispose() {
    _stopVibration();
    _textAnimationTimer?.cancel();
    super.dispose();
  }

  void _startTextAnimation() {
    _textAnimationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _dots = _dots.length >= 3 ? '' : _dots + '.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC 읽기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 2,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: _isReading
                        ? Lottie.asset('assets/nfcAnime.json')
                        : SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          children: [
                            TextSpan(text: _baseText),
                            TextSpan(text: _dots),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isRetryVisible)
              IconButton(
                icon: Icon(Icons.refresh),
                iconSize: 48,
                onPressed: () {
                  setState(() {
                    _isRetryVisible = false;
                  });
                  _startNfcRead();
                },
                tooltip: '다시 시도',
              ),
          ],
        ),
      ),
    );
  }

  void _startNfcRead() {
    setState(() {
      _isReading = true;
    });

    _startVibration();

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          return;
        }
        var records = await ndef.read();
        // NFC 태그 데이터 처리 로직
        // 여기에 태그 데이터를 처리하는 코드를 추가하세요
      } catch (e) {
        // 오류 처리
        print('NFC 읽기 오류: $e');
      } finally {
        _stopNfcRead();
      }
    });

    // 30초 후에 자동으로 중지 및 "다시 시도" 버튼 표시
    Future.delayed(Duration(seconds: 30), () {
      if (_isReading) {
        _stopNfcRead();
        setState(() {
          _isRetryVisible = true;
        });
      }
    });
  }

  void _stopNfcRead() {
    NfcManager.instance.stopSession();
    _stopVibration();
    _textAnimationTimer?.cancel();
    setState(() {
      _isReading = false;
    });
  }

  void _startVibration() {
    _stopVibration();
    _vibrationTimer = Timer.periodic(Duration(milliseconds: 1400), (timer) {
      Vibration.vibrate(duration: 150);
    });
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    Vibration.cancel();
  }
}