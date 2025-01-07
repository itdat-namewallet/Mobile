import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/expanded_card_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';
import 'package:itdat/widget/card/info_widget.dart';
import 'package:itdat/widget/card/portfolio_widget.dart';
import 'package:itdat/widget/card/history_widget.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardScreen> {

  late String _userEmail;
  late Future<List<dynamic>> _businessCards;
  BusinessCard? selectedCardInfo;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  int _cardIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  // 로그인 이메일로 명함 데이터 가져오기
  Future<void> _loadEmail() async {
    final storage = FlutterSecureStorage();
    String? userEmail = await storage.read(key: 'email');

    if(userEmail != null){
      setState(() {
        _userEmail = userEmail;
        _businessCards = CardModel().getBusinessCard(_userEmail);
      });
    }else{
      setState(() {
        Navigator.pushReplacementNamed(context, '/');
      });
    }
  }


  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No2(cardInfo: cardInfo); // 기본값
    }
  }


  // 명함의 총 개수를 알 수 있고 아이콘 클릭 시 해당 명함 렌더링
  Widget renderCardSlideIcon(List<dynamic> filteredCards) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(filteredCards.length + 1, (index) {
        if (index == filteredCards.length) {
          return IconButton(
            icon: Icon(
              Icons.add,
              size: 15,
              color: Theme.of(context).iconTheme.color
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateSelectionScreen(userEmail: _userEmail),
                ),
              );
            },
          );
        } else {
          return IconButton(
            icon: Icon(
              Icons.circle,
              size: 10,
              color: index == _cardIndex
                  ? const Color.fromRGBO(0, 202, 145, 1)
                  : Theme.of(context).iconTheme.color
            ),
            onPressed: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {
                _cardIndex = index;
              });
            },
          );
        }
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _businessCards,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('명함을 가져오는 중 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // 현재 저장된 명함이 없다면 명함 추가 버튼 렌더링
                  return Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateSelectionScreen(userEmail: _userEmail),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 64),
                    ),
                  );
                } else {

                  // 최근 만들어진 순으로 정렬
                  var businessCards = snapshot.data!
                      .map((data) => BusinessCard.fromJson(data))
                      .toList()..sort((a, b) => b.cardNo!.compareTo(a.cardNo!));

                  // 명함 앞면만 렌더링 / 뒷면은 명함 클릭 시 볼 수 있음
                  var filteredCards = businessCards
                      .where((card) => card.cardSide == 'FRONT' && card.userEmail == _userEmail)
                      .toList();

                  return Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: filteredCards.length + 1,
                          onPageChanged: (index) {
                            setState(() {
                              _cardIndex = index;
                              if (index < filteredCards.length) {
                                selectedCardInfo = filteredCards[index];
                              }
                            });
                          },
                          // 항상 명함 마지막 슬라이드에 명함 추가 버튼 렌더링
                          itemBuilder: (context, index) {
                            if (index == filteredCards.length) {
                              return Center(
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TemplateSelectionScreen(userEmail: _userEmail),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 64),
                                ),
                              );
                            } else {
                              var cardInfo = filteredCards[index];

                              // 명함 슬라이드 렌더링
                              return GestureDetector(
                                onTap: (){
                                  BusinessCard? backCard;
                                  for (var cardItem in businessCards) {
                                    if (cardItem.cardNo == cardInfo.cardNo && cardItem.cardSide == 'BACK') {
                                      backCard = cardItem;
                                      break;
                                    }
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context)=> ExpandedCardScreen(
                                          cardInfo: cardInfo, backCard:backCard
                                      ),
                                    )
                                  );
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                                  child: LayoutBuilder( // 부모의 크기를 알 수 있도록 LayoutBuilder 사용
                                    builder: (context, constraints) {
                                      // constraints.maxHeight를 사용하여 높이를 제한
                                      double cardHeight = constraints.maxHeight; // 부모 높이에 맞게 설정
                                      return SingleChildScrollView(
                                        child: Container(
                                          height: cardHeight, // 높이를 명시적으로 설정
                                          child: buildBusinessCard(cardInfo),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      // 슬라이드 아이콘
                      renderCardSlideIcon(filteredCards),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: const Text("연락처"),
                    ),
                    const Text("|"),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: const Text("포트폴리오"),
                    ),
                    const Text("|"),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                      child: const Text("히스토리"),
                    ),
                  ],
                ),
                Expanded(
                  child: _selectedIndex == 0 && selectedCardInfo != null
                      ? InfoWidget(businessCards: selectedCardInfo!)
                      : _selectedIndex == 1
                      ? const PortfolioWidget()
                      : const HistoryWidget(),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
