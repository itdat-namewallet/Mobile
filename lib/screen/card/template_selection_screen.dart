import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/form_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

class TemplateSelectionScreen extends StatefulWidget {

  final String userEmail;

  const TemplateSelectionScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {

  Map<String, dynamic>? userData;
  late BusinessCard _card;
  late List<Widget> templates;
  bool isLoading = true;
  int cardNo = 1;
  String selectedTemplate = "";

  @override
  void initState() {
    super.initState();
    fetchUserDataAndBusinessCards();
  }


  // 기존 정보 가져오기
  Future<void> fetchUserDataAndBusinessCards() async {
    setState(() => isLoading = true);

    try {
      final fetchedUserData = await CardModel().getUserById(widget.userEmail);
      final fetchedBusinessCards = await CardModel().getBusinessCard(widget.userEmail);

      setState(() {
        userData = fetchedUserData;
        cardNo = (fetchedBusinessCards.length) + 1;
        _initializeCard();
      });
    } catch (e) {
      print("유저 기본 정보, 카드 정보 가져오기 실패 : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  // 명함 정보 초기화
  void _initializeCard() {
    _card = BusinessCard(
      appTemplate: "",
      userName: userData?['userName'] ?? "",
      phone: userData?['phone'] ?? "",
      email: userData?['userEmail'] ?? "",
      companyName: userData?['company'] ?? "",
      companyNumber: userData?['companyPhone'] ?? "",
      companyAddress:
      "${userData?['companyAddr'] ?? ""} ${userData?['companyAddrDetail'] ?? ""}",
      companyFax: userData?['companyFax'] ?? "",
      department: userData?['companyDept'] ?? "",
      position: userData?['companyRank'] ?? "",
      userEmail: widget.userEmail,
      cardNo: cardNo,
      cardSide: "FRONT",
    );

    // 템플릿 초기화
    templates = [
      No1(cardInfo: _card),
      No2(cardInfo: _card),
      No3(cardInfo: _card),
    ];

    print(_card);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("템플릿 선택")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, i) {
              final template = templates[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTemplate = "No${i + 1}";
                    _card = _card.copyWith(appTemplate: selectedTemplate);
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(cardInfo: _card),
                      )
                  );
                },
                child: Transform.scale(
                  scale: 0.9,
                  child: Container(
                    child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: template
                    ),
                  ),
                )
              );
            },
      ),
    );
  }
}

