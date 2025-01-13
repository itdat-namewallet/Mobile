import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/expanded_card_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';
import 'package:itdat/widget/card/card_info_widget.dart';
import 'package:itdat/widget/card/portfolio/portfolio_widget.dart';
import 'package:itdat/widget/card/history/history_widget.dart';



class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardScreen> {

  late String _loginEmail;
  late Future<List<dynamic>>? _businessCards;
  BusinessCard? selectedCardInfo;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  int _cardIndex = 0;

  @override
  void initState() {
    super.initState();
    _businessCards = null;
    _loadEmail();
  }

  // 카드 정보 초기화
  void _setInitialCard(List<dynamic> filteredCards) {
    if (filteredCards.isNotEmpty && selectedCardInfo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedCardInfo = filteredCards[0];
        });
      });
    }
  }


  // 로그인 이메일로 명함 데이터 가져오기
  Future<void> _loadEmail() async {
    final storage = FlutterSecureStorage();
    final userEmail = await storage.read(key: 'user_email');

    if (userEmail != null) {
      setState(() {
        _loginEmail = userEmail;
        _businessCards = CardModel().getBusinessCard(_loginEmail);
      });
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = screenWidth * 0.9; // 화면 너비의 90%
    final cardHeight = screenHeight * 0.3; // 화면 높이의 30%

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: _getTemplateWidget(cardInfo),
      ),
    );
  }

  Widget _getTemplateWidget(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo,);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No2(cardInfo: cardInfo);
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
                  builder: (context) => TemplateSelectionScreen(userEmail: _loginEmail),
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
                // 데이터 로딩 중
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 에러 발생 시
                else if (snapshot.hasError) {
                  return const Center(child: Text('명함을 가져오는 중 오류가 발생했습니다.'));
                }
                // 데이터가 없을 경우
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: IconButton(
                      onPressed: () {
                        if (_loginEmail != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TemplateSelectionScreen(userEmail: _loginEmail!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("로그인이 필요합니다.")),
                          );
                        }
                      },
                      icon: const Icon(Icons.add, size: 64),
                    ),
                  );
                }

                // 명함 데이터 처리
                var businessCards = snapshot.data!
                    .map((data) => BusinessCard.fromJson(data))
                    .toList()
                  ..sort((a, b) => b.cardNo!.compareTo(a.cardNo!));

                // 앞면 명함 필터링
                var filteredCards = businessCards
                    .where((card) => card.cardSide == 'FRONT' && card.userEmail == _loginEmail)
                    .toList();

                // 초기 명함 설정
                _setInitialCard(filteredCards);

                return Column(
                  children: [
                    Flexible(
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
                        itemBuilder: (context, index) {
                          if (index == filteredCards.length) {
                            return Center(
                              child: IconButton(
                                onPressed: () {
                                  if (_loginEmail != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TemplateSelectionScreen(userEmail: _loginEmail!),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add, size: 64),
                              ),
                            );
                          } else {
                            var cardInfo = filteredCards[index];

                            return GestureDetector(
                              onTap: () {
                                BusinessCard? backCard;
                                for (var businessCard in businessCards) {
                                  if (businessCard.cardNo == cardInfo.cardNo &&
                                      businessCard.cardSide == 'BACK') {
                                    backCard = businessCard;
                                    break;
                                  }
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExpandedCardScreen(
                                      cardInfo: cardInfo,
                                      backCard: backCard,
                                    ),
                                  ),
                                );
                              },
                              child: buildBusinessCard(cardInfo, context),
                            );
                          }
                        },
                      ),
                    ),
                    renderCardSlideIcon(filteredCards),
                  ],
                );
              },
            ),
          ),
          // 하단 위젯
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
                      ? CardInfoWidget(businessCards: selectedCardInfo!)
                      : _selectedIndex == 1
                      ? PortfolioWidget(loginUserEmail: _loginEmail, cardUserEmail: _loginEmail)
                      : HistoryWidget(loginUserEmail: _loginEmail, cardUserEmail: _loginEmail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
