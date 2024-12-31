import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No2 extends StatelessWidget {
  final BusinessCard cardInfo;

  No2({
    super.key,
    required this.cardInfo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  cardInfo.companyName ?? "",
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800,),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(cardInfo.position ?? "",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      cardInfo.userName ?? "",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(cardInfo.department?? "",
                  style: const TextStyle(fontSize: 15),),
                const Divider(thickness: 1, color: Colors.grey),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("M. ", style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(cardInfo.phone ?? ""),
                    const SizedBox(width: 10,),
                    if(cardInfo.email != null && cardInfo.email!.isNotEmpty)
                      const Text("E. ", style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(cardInfo.email ?? ""),
                  ],
                ),
                Row(
                  children: [
                    if(cardInfo.companyNumber != null && cardInfo.companyNumber!.isNotEmpty)
                      ...[
                        const Text("T. ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(cardInfo.companyNumber ?? ""),
                        const SizedBox(width: 10,),
                      ],
                    if(cardInfo.companyFax != null && cardInfo.companyFax!.isNotEmpty)
                      ...[
                        const Text("F. ", style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(cardInfo.companyFax?? ""),
                      ],
                  ],
                ),
                Text(cardInfo.companyAddress ?? ""),
              ],
            )
          ],
        ),
    );
  }
}
