import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/User/static_user.dart';
import 'board/homeboard.dart';
import '../Model/board/boardlisttest.dart';

class BoardListPage extends StatefulWidget {
  const BoardListPage({super.key});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  late TextEditingController selectController = TextEditingController();
  late TextEditingController val1 = TextEditingController();
  late String searchTexts = "";
  late List data = [];
  late int poId = 0;
  Boarder boardstartI = Boarder();

  @override
  void initState() {
    super.initState();
    selectUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: 40,
        actions: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.65,
                color: Colors.white,
                // 앱바 검색
                child: TextField(
                  controller: selectController,
                  onChanged: (text) {
                    searchTexts = selectController.text;
                    setState(() {
                      //
                    });
                  },
                  decoration: const InputDecoration(hintText: "검색"),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                searchTexts = selectController.text;
                setState(() {});
              },
              icon: const Icon(Icons.search),
              color: Colors.black,
            ),
            // IconButton(
            //   onPressed: () {
            //     // 공지사항으로 이동
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: ((context) => const Declaration()),
            //         ));
            //   },
            //   icon: const Icon(Icons.notifications),
            //   color: Colors.black,
            // ),
          ]),
        ],
      ),
      // 검색한 거 넘김
      body: Homeboard(
        searchText: searchTexts,
      ),
    );
  }

  // 유저 정보를 static에 담는다.
  selectUserInfo() async {
    String? uId = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(uId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        print('데이터: ${documentSnapshot.data()}');
        Map<String, dynamic>? data = documentSnapshot.data();

        StaticUser.userId = uId!;
        StaticUser.userName = data!['userName'];
        StaticUser.userAddress = data['userAddress'];
        StaticUser.userPw = data['userPw'];
        StaticUser.userReliability = data['userReliability'];
      } else {
        print('Document does not exist on the database');
      }

      print("static user id: ${StaticUser.userId}");
      print("static user name: ${StaticUser.userName}");
      print("auth id: ${FirebaseAuth.instance.currentUser?.uid}");
    });
  }
} // END
