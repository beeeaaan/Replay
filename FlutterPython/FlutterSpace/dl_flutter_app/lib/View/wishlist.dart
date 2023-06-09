import 'package:dl_flutter_app/Model/User/static_user.dart';
import 'package:dl_flutter_app/Model/mypage_list/list.dart';
import 'package:flutter/material.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  late ListModel handler;
  late String userId;
  late int poId; // 찜 목록 삭제를 위한 것

  @override
  void initState() {
    super.initState();
    handler = ListModel();
    userId = StaticUser.userId;
    poId = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('찜 목록', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 243, 242, 239),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: FutureBuilder(
        future: handler.wishlistSelect(userId),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          // 로딩 중일 때
          if (snapshot.data == null) {
            return Container();
          } else {
            // 로딩 뒤에 데이터가 비었는지 있는지에 따라
            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                '찜한 목록이 없습니다.',
                style: TextStyle(fontSize: 25, color: Colors.black26),
              ));
            }
            // 여기가 로딩 뒤에 데이터가 있을 떄
            else {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  return wishBuild(context, index, snapshot);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget wishBuild(BuildContext context, int index, AsyncSnapshot snapshot) {
    return Card(
      clipBehavior: Clip.antiAlias, // 테두리 부드럽게 만드려고 사용
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 82,
                        child: Image.network(
                            "http://localhost:8080/images/${snapshot.data[index]['poImage01']}"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          snapshot.data[index]['poTitle'].toString(),
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        snapshot.data[index]['poPrice'].toString(),
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      snapshot.data[index]['poState'] == 0
                          ? const SizedBox(
                              width: 65,
                              height: 35,
                              child: Card(
                                color: Colors.grey,
                                child: Center(
                                  child: Text(
                                    '판매 완료',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 65,
                              height: 35,
                              child: Card(
                                color: Colors.grey,
                                child: Center(
                                  child: Text(
                                    '판매 중',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      await _deleteWish(
                        snapshot.data[index]['poId'],
                      );
                      print(snapshot.data[index]['poId']);
                      refresh();
                      await wishDownpoHeart(snapshot.data[index]['poId']);
                    },
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.black38,
                      ),
                      Text(
                        snapshot.data[index]['poHeart'].toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 찜 목록 삭제
  _deleteWish(poId) async {
    handler = ListModel();
    handler.deleteWish(userId, poId);
  }

  // 찜 목록 초기화(삭제하고 바로 반영되도록)
  refresh() {
    setState(() {});
  }

  // 찜 목록 제거시 하트수 -1
  wishDownpoHeart(poId) {
    handler = ListModel();
    handler.wishDownpoHeart(poId);
  }
}
