import 'package:eyehelper/controller/main_controller.dart';
import 'package:eyehelper/view/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with MainController {
  @override
  void initState() {
    initialCamera();
    initialSpeaker();
    initializeLabeler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => goToCam.value
        ? CameraPage(
            onComplete: onTapCamera,
            back: () {
              goToCam.value = false;
            },
            repeat: () {
              repeatPlay();
            },
          )
        : Scaffold(
            backgroundColor: Colors.black87,
            body: Container(
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                        ),
                        Obx(() => Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    'Last Accent:  ${database.value}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  )),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Change Accent:           ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            futureBuilder(),
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 95, bottom: 20),
                            child: InkWell(
                              onTap: () {
                                goToCam.value = true;
                              },
                              child: Container(
                                height: 60,
                                width: 160,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Take a photo',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    )))));
  }
}
