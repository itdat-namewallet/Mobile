import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('서비스 이용약관')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '''
서비스 이용약관

제 1 조 (목적)
본 약관은 회사(이하 "회사")가 제공하는 모든 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제 2 조 (정의)
1. "서비스"란 회사가 제공하는 모든 온라인 서비스를 말합니다.
2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 모든 고객을 말합니다.

제 3 조 (약관의 게시와 개정)
1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 공지하며, 이용자가 이에 동의함으로써 효력이 발생합니다.
2. 회사는 필요에 따라 약관을 개정할 수 있으며, 개정된 약관은 공지된 날로부터 7일 후 효력이 발생합니다.

제 4 조 (서비스의 제공 및 변경)
1. 회사는 이용자에게 다양한 콘텐츠와 서비스를 제공합니다.
2. 회사는 서비스의 일부 또는 전부를 변경하거나 종료할 수 있으며, 이에 대한 사항은 사전에 공지합니다.

제 5 조 (이용자의 의무)
1. 이용자는 서비스를 불법적으로 사용해서는 안 됩니다.
2. 이용자는 본 약관 및 관련 법령을 준수해야 합니다.

제 6 조 (책임의 제한)
1. 회사는 천재지변 등 불가항력으로 인한 손해에 대해 책임을 지지 않습니다.
2. 회사는 이용자의 귀책사유로 인한 서비스 이용 장애에 대해 책임을 지지 않습니다.

제 7 조 (분쟁 해결)
본 약관과 관련하여 발생하는 모든 분쟁은 대한민국 법률에 따라 해결합니다.

부칙
본 약관은 2025년 1월 1일부터 시행됩니다.
          ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
