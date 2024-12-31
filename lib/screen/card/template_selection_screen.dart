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

  final CardModel cardModel = CardModel();
  Map<String, dynamic>? userData;
  late BusinessCard _card;
  late List<Widget> templates;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCard();
    fetchUserData();
  }

  void _initializeCard() {
    _card = BusinessCard(
      appTemplate: "",
      userName: "",
      phone: "",
      email: "",
      companyName: "",
      companyNumber: "",
      companyAddress: "",
      companyFax: "",
      department: "",
      position: "",
      userEmail: widget.userEmail,
    );

    // templates 초기화
    templates = [
    No1(cardInfo: _card),
    No2(cardInfo: _card),
    No3(cardInfo: _card),
    ];
  }



// 유저 정보 가져오기
  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final data = await cardModel.getUserById(widget.userEmail);
      setState(() {
        userData = data;
        _initializeCardWithUserData();
      });
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
      print("유저: $userData");
    }
  }


  // 명함 초기화
    void _initializeCardWithUserData() {
      if (userData != null) {
        setState(() {
          _card = _card.copyWith(
            appTemplate: selectedTemplate,
            userName: userData!['userName'] ?? "",
            phone: userData!['phone'] ?? "",
            email: userData!['userEmail'] ?? "",
            companyName: userData!['company'] ?? "",
            companyNumber: userData!['companyPhone'] ?? "",
            companyAddress:
            "${userData!['companyAddr'] ?? ""} ${userData!['companyAddrDetail'] ?? ""}",
            companyFax: userData!['companyFax'] ?? "",
            department: userData!['companyDept'] ?? "",
            position: userData!['companyRank'] ?? "",
            userEmail: userData!['userEmail'] ?? "",
          );

          // 데이터가 업데이트된 후 templates를 다시 초기화
          templates = [
            No1(cardInfo: _card),
            No2(cardInfo: _card),
            No3(cardInfo: _card),
          ];
        });
      }
  }

  String selectedTemplate = "";


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

