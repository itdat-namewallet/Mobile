import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:itdat/models/nfc_model.dart';

class NfcReadPage extends StatefulWidget {
  @override
  _NfcReadPageState createState() => _NfcReadPageState();
}

class _NfcReadPageState extends State<NfcReadPage> {
  bool _isReading = false;
  bool _isRetryVisible = false;
  bool _isNfcAvailable = false;
  Timer? _vibrationTimer;
  late String _baseText;
  String _dots = '';
  Timer? _textAnimationTimer;
  final NfcModel _nfcModel = NfcModel();

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _startTextAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _baseText = AppLocalizations.of(context)!.nfctag;
  }

  @override
  void dispose() {
    _stopVibration();
    _textAnimationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNfcAvailable = isAvailable;
    });
    if (isAvailable) {
      _startNfcRead();
    } else {
      _showNfcNotAvailableAlert();
    }
  }

  void _showNfcNotAvailableAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.nfcNotAvailable),
          content: Text(AppLocalizations.of(context)!.nfcNotAvailableMessage),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // NFC 읽기 페이지를 닫습니다.
              },
            ),
          ],
        );
      },
    );
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
        title: Text(AppLocalizations.of(context)!.nfcread),
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
                    child: _isReading && _isNfcAvailable
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
            if (_isRetryVisible && _isNfcAvailable)
              IconButton(
                icon: Icon(Icons.refresh),
                iconSize: 48,
                onPressed: () {
                  setState(() {
                    _isRetryVisible = false;
                  });
                  _startNfcRead();
                },
                tooltip: AppLocalizations.of(context)!.retryTooltip,
              ),
          ],
        ),
      ),
    );
  }

  void _startNfcRead() {
    if (!_isNfcAvailable) {
      _showNfcNotAvailableAlert();
      return;
    }

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
        var message = await ndef.read();
        if (message != null && message.records.isNotEmpty) {
          var record = message.records.first;
          if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
              record.type.length == 1 &&
              record.type[0] == 0x54) { // 'T' for Text record
            var languageCodeLength = record.payload[0] & 0x3f;
            var text = utf8.decode(record.payload.sublist(1 + languageCodeLength));
            var cardInfo = json.decode(text);
            await _processCardInfo(cardInfo);
          }
        }
      } catch (e) {
        print('NFC 읽기 오류: $e');
        _showErrorAlert(AppLocalizations.of(context)!.nfcReadError);
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

  Future<void> _processCardInfo(Map<String, dynamic> cardInfo) async {
    try {
      print('Processing card info: $cardInfo');
      await _nfcModel.processCardInfo(cardInfo);
      _showSuccessAlert(AppLocalizations.of(context)!.cardProcessSuccess);
    } catch (e) {
      print('카드 정보 처리 오류: $e');
      _showErrorAlert(AppLocalizations.of(context)!.cardProcessError);
    }
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

  void _stopNfcRead() {
    NfcManager.instance.stopSession();
    _stopVibration();
    setState(() {
      _isReading = false;
    });
  }

  void _showSuccessAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.success),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () async {
                _stopNfcRead();
                Navigator.of(context).popUntil((route) => route.isFirst);
                await Navigator.of(context).pushReplacementNamed('/main', arguments: {'refresh': true});
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.error),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}