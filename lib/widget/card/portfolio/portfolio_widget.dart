import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:itdat/widget/card/portfolio/post_box.dart';
import 'package:itdat/widget/card/portfolio/write_post.dart';

class PortfolioWidget extends StatefulWidget {
  final String loginUserEmail;
  final String cardUserEmail;

  const PortfolioWidget({
    super.key,
    required this.loginUserEmail,
    required this.cardUserEmail
  });

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final fetchedPosts = await BoardModel().getPosts(widget.cardUserEmail);
    fetchedPosts.sort((a, b) => b['id'].compareTo(a['id']));
    setState(() {
      posts = fetchedPosts;
    });
  }

  void _goToWritePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePost(onPostSaved: _fetchPosts, userEmail: widget.loginUserEmail,),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: posts.isEmpty
          ? widget.cardUserEmail == widget.loginUserEmail
            ? Center(child: Text('포트폴리오를 작성해주세요.', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,)))
            : Center(child: Text('포트폴리오가 없습니다.', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,)))
          : ListView.builder(
        physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
        shrinkWrap: true, // 부모 컨테이너 크기에 맞춤
        padding: EdgeInsets.all(8.0),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PostBox(
              post: post,
              currentUserEmail: widget.loginUserEmail,
              onPostModified: _fetchPosts,
            ),
          );
        },
      ),
      floatingActionButton: widget.cardUserEmail == widget.loginUserEmail
          ? FloatingActionButton(
              onPressed: _goToWritePost,
              backgroundColor: Colors.transparent,
              elevation: 0,
              splashColor: Colors.transparent,
              highlightElevation: 0,
              child: Image.asset('assets/icons/addBoard.png', height: 30, width: 30, color: isDarkMode ? Colors.grey[200] : Colors.black,),
            )
          : null,
    );
  }
}
