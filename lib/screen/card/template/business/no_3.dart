import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/utils/HttpClientManager.dart';
import '../../../../widget/setting/waitwidget.dart';

class No3 extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  No3({
    super.key,
    required this.cardInfo,
    this.image,
  });

  TextStyle _buildTextStyle({
    required Color? textColor,
    required String? fontFamily,
    double fontSize = 17,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.getFont(
      fontFamily ?? 'Nanum Gothic',
      color: textColor ?? Colors.black87,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  String getFullImageUrl() {
    final baseUrl = "${dotenv.env['BASE_URL']}";
    if (cardInfo.logoUrl != null &&
        (cardInfo.logoUrl!.startsWith('http://') || cardInfo.logoUrl!.startsWith('https://'))) {
      return cardInfo.logoUrl!;
    } else {
      return '$baseUrl/${cardInfo.logoUrl ?? ""}';
    }
  }


  Future<bool> checkFileExists(String url) async {
    final client = await HttpClientManager().createHttpClient();
    try {
      final response = await client.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }



  Color hexToColor(String? hex, {Color fallback = Colors.white}) {
    if (hex == null || hex.isEmpty) {
      return fallback;
    }
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = hexToColor(cardInfo.backgroundColor, fallback:Colors.white);
    Color textColor = hexToColor(cardInfo.textColor, fallback: Colors.black87);

    return Container(
      width: 420,
      height: 255,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<bool>(
            future: checkFileExists(getFullImageUrl()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return WaitAnimationWidget();
              } else if (snapshot.hasData && snapshot.data == true) {
                return Image.network(
                  getFullImageUrl(),
                  height: 50,
                  fit: BoxFit.contain,
                );
              } else if (image != null) {
                return Image.file(
                  image!,
                  height: 50,
                  fit: BoxFit.contain,
                );
              } else {
                return Text(
                  cardInfo.companyName ?? "회사 이름",
                  style: _buildTextStyle(
                    textColor: textColor,
                    fontFamily: cardInfo.fontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
          SizedBox(width: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    cardInfo.position ?? "",
                    style: _buildTextStyle(
                      textColor: textColor,
                      fontFamily: cardInfo.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    cardInfo.userName ?? "",
                    style: _buildTextStyle(
                      textColor: textColor,
                      fontFamily: cardInfo.fontFamily,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ),
              Text(
                cardInfo.department ?? "",
                style: _buildTextStyle(
                  textColor: textColor,
                  fontFamily: cardInfo.fontFamily,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: textColor),
              Text(
                cardInfo.phone ?? "",
                style: _buildTextStyle(
                  textColor: textColor,
                  fontFamily: cardInfo.fontFamily,
                ),
              ),
              if (cardInfo.email != null && cardInfo.email!.isNotEmpty) ...[
                Text(
                  cardInfo.email ?? "",
                  style: _buildTextStyle(
                    textColor: textColor,
                    fontFamily: cardInfo.fontFamily,
                  ),
                ),
              ],
              Text(
                cardInfo.companyAddress ?? "",
                style: _buildTextStyle(
                  textColor: textColor,
                  fontFamily: cardInfo.fontFamily,
                ),
              ),
              if (cardInfo.companyNumber != null &&
                  cardInfo.companyNumber!.isNotEmpty) ...[
                Text(
                  cardInfo.companyNumber ?? "",
                  style: _buildTextStyle(
                    textColor: textColor,
                    fontFamily: cardInfo.fontFamily,
                  ),
                ),
              ],
              if (cardInfo.companyFax != null &&
                  cardInfo.companyFax!.isNotEmpty) ...[

                Text(
                  cardInfo.companyFax ?? "",
                  style: _buildTextStyle(
                    textColor: textColor,
                    fontFamily: cardInfo.fontFamily,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
