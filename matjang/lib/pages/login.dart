import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:matjang/model/socialLogin.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../model/usermodel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static const storage = FlutterSecureStorage(
      iOptions: IOSOptions(
    synchronizable: false,
    accessibility: KeychainAccessibility.first_unlock,
  ));
  UserModel? user;

  @override
  void initState() {
    super.initState();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    // await storage.deleteAll();
    var loginKakao = await storage.read(key: "login-kakao");
    var loginApple = await storage.read(key: "login-apple");

    //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
    if (loginKakao != null) {
      // var result = await FirebaseFirestore.instance.collection("users").doc(login).get();
      Provider.of<UserModel>(context, listen: false)
          .setEmailAndType(loginKakao, SocialType.Kakao);

      Get.toNamed("/mapTest", arguments: {"email": "$loginKakao&kakao"});
    } else if (loginApple != null) {
      Provider.of<UserModel>(context, listen: false)
          .setEmailAndType(loginApple, SocialType.Apple);

      Get.toNamed("/mapTest", arguments: {"email": "$loginApple&apple"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                user = await SocialLogin()
                    .socialLogin(socialType: SocialType.Kakao);

                if (user?.email != null) {
                  Provider.of<UserModel>(context, listen: false)
                      .setEmailAndType(user?.email ?? "", SocialType.Kakao);

                  await storage.write(key: "login-kakao", value: user?.email);

                  FirebaseFirestore.instance
                      .collection("users")
                      .doc("${user?.email}&kakao")
                      .set({"matjip": [], "following": [], "review": {}});

                  setState(() {});

                  Get.toNamed("/mapTest",
                      arguments: {"email": "${user?.email}&kakao"});
                } else {
                  return;
                }
              },
              child: Image.asset("assets/images/kakao_login_medium_narrow.png",
                  width: 200, fit: BoxFit.contain)),
          const SizedBox(height: 30),
          SignInWithAppleButton(onPressed: () async {
            user =
                await SocialLogin().socialLogin(socialType: SocialType.Apple);

            if (user?.email != null) {
              Provider.of<UserModel>(context, listen: false)
                  .setEmailAndType(user?.email ?? "", SocialType.Apple);

              await storage.write(key: "login-apple", value: user?.email);

              FirebaseFirestore.instance
                  .collection("users")
                  .doc("${user?.email}&apple")
                  .set({"matjip": [], "following": [], "review": {}});

              setState(() {});

              Get.toNamed("/mapTest",
                  arguments: {"email": "${user?.email}&apple"});
            } else {
              return;
            }
          })
        ],
      ),
    );
  }
}
