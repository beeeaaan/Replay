import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../Widget/Alert/Snackbar.dart';
import '../../tabbar.dart';
import '../boardlist_page.dart';

class UpdateBorad extends StatefulWidget {
  const UpdateBorad(
      {super.key,
      required this.poId,
      required this.poTitle,
      required this.poContent,
      required this.poPrice,
      required this.poImage});
  final int poId;
  final String poTitle;
  final String poContent;
  final String poPrice;
  final String poImage;

  @override
  State<UpdateBorad> createState() => _UpdateBoradState();
}

class _UpdateBoradState extends State<UpdateBorad> {
  late TextEditingController titleController =
      TextEditingController(text: widget.poTitle);
  late TextEditingController priceController =
      TextEditingController(text: widget.poPrice);
  late TextEditingController contentController =
      TextEditingController(text: widget.poContent);
  late bool insertBoard = false;
  late String imagefile = "";
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late Image cameraImage;
  late String poimage = widget.poImage;
  boarderTextStyle(Color? color) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  Snackbar snackbar = Snackbar();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraImage = Image.network(
      "http://localhost:8080/images/$poimage",
      fit: BoxFit.fill,
      width: 300,
      height: 250,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          // (취소) -- 내 물건 팔기 --  [완료]
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // 취소가 되야 돼
                  // 팝으로 넘어가는데 게시판 상태가 갱신이 안됨,
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 79,
              ),
              Text(
                "상품 등록 수정",
                style: boarderTextStyle(Colors.black),
              ),
              const SizedBox(
                width: 79,
              ),
              TextButton(
                onPressed: () {
                  /// 완료하면 인서트 해야 되는데
                  String name = titleController.text;
                  if (titleController.text.isNotEmpty &&
                      priceController.text.isNotEmpty &&
                      contentController.text.isNotEmpty &&
                      imagefile != "") {
                    insertBoard = true;
                    if (insertBoard == true) {
                      modifyBoard(
                          widget.poId,
                          titleController.text,
                          contentController.text,
                          priceController.text,
                          imagefile);
                      pushHome();
                    }
                  } else {
                    insertBoard = false;
                  }
                  // snackbar 출력
                  insertBoard
                      ? snackbar.MySnackbar(context, "입력완료")
                      : snackbar.MySnackbar(context, "다시입력해주세요");

                  /// 1. 값 다 입력했는지 확인 및 정규화
                  /// 2. true 일 때만 입력해야 됨
                },
                child: Text(
                  "완료",
                  style: boarderTextStyle(Colors.black),
                ),
              ),
            ],
          ),
          Container(
              color: Colors.white,
              width: 300,
              height: 250,
              child: Column(
                children: [
                  _image == null
                      ? cameraImage
                      : Image.file(
                          _image!,
                          fit: BoxFit.fill,
                          width: 300,
                          height: 250,
                        ),
                ],
              )),
          // 사진 올리는 버튼
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
                onPressed: () {
                  imageToServe();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  "사진 올리기 ",
                  style: boarderTextStyle(Colors.white),
                )),
          ),
          // ===========
          // 글 제목
          TextField(
            maxLength: 30,
            controller: titleController,
            decoration: const InputDecoration(hintText: "글 제목"),
          ),
          // 가격
          TextField(
              maxLength: 11,
              controller: priceController,
              decoration: const InputDecoration(hintText: "가격 : 숫자만 입력가능"),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
              ]),
          // 내용 (힌트로 작성법 설명)
          TextField(
            maxLength: 400,
            maxLines: 10,
            controller: contentController,
            decoration: const InputDecoration(
                hintText: "게시글 내용을 작성해주세요",
                contentPadding: EdgeInsets.symmetric(vertical: 20)),
          )

          // 거래 희망장소 (편의점 선택) -> 폴리움 할 수 있게
          // 끝?
        ],
      ),
    );
  } ////

  // image
  Future<void> imageToServe() async {
    final XFile? selectImage = await _picker.pickImage(
      maxWidth: 300,
      maxHeight: 250,
      source: ImageSource.gallery, //위치는 갤러리
    );
    if (selectImage != null) {
      setState(() {
        _image = File(selectImage.path);
      });
      dynamic sendData = selectImage.path;
      var formData =
          FormData.fromMap({'image': await MultipartFile.fromFile(sendData)});
      patchUserProfileImage(formData);
    }
  }

  // image
  Future<dynamic> patchUserProfileImage(dynamic input) async {
    var dio = new Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;
      var response = await dio.patch(
        'http://localhost:8080/src/main/resources/static/images/',
        data: input,
      );
      imagefile = response.data;
      return imagefile;
    } catch (e) {}
  } //

  // TextField에 입력한 값을 받아와서 poTitle,poContent,poPrice,poImage01은 입력하고
  // 나머지는 기본값으로 준다. poUser의 경우는 나중에 로그인한 아이디로 처리하자.
  // post 테이블에 inset
  Future<int> modifyBoard(
      int Id, String title, String content, String price, String image) async {
    // var enginSizeCC = (engineSize + 1) * 1000;
    // poHeart,poTitle,poContent,poPrice,poImage01,poViews,poState,poUser
    int poId = Id;
    String poTitle = title;
    String poContent = content;
    String poPrice = price;
    String poImage01 = image;
    var url = Uri.parse(
        "http://localhost:8080/post/modify?poTitle=$poTitle&poContent=$poContent&poPrice=$poPrice&poImage01=$poImage01&poId=$poId");
    var response = await http.get(url);
    makemodifyDate(poId);
    return 0;
  }

  // Post에 insert했으면 그 PoId를 가져와야 한다.
  // 똑같이 입력한 값을 가지고 select 해서 ID 찾아서 Upload로 넘기자

  // uploadInsert
  Future<int> makemodifyDate(int id) async {
    // int poHeart = 0;
    int poId = id;
    String U_userId = "korea";
    var url =
        Uri.parse("http://localhost:8080/post/modifyboard/$poId/$U_userId");
    var response = await http.get(url);
    return 0;
  }

  Future pushHome() async {
    await Future.delayed(const Duration(seconds: 2));
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Tabbar(),
        ),
        (route) => false);
  }

// Future.delayed(Duration(seconds: 3));
} ///// END