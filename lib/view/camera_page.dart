// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_web_libraries_in_flutter

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eyehelper/controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    final Key? key,
    required this.onComplete,
    required this.back,
    required this.repeat,
  }) : super(key: key);

  final ValueChanged<String> onComplete;
  final VoidCallback back;
  final VoidCallback repeat;

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  bool showCam = false; // show camera
  late CameraController cameraController; // camera controller
  int cameraindex = 0; // list of camera
  bool takePhotoReady = false; // show taked image
  late XFile imageFile; // taked image file
  bool cameraInitial = false;

  @override
  void initState() {
    initialCamera();

    super.initState();
  }

  void initialCamera() {
    cameraController = CameraController(
      cameras[cameraindex], // set camera
      ResolutionPreset.max, // set resolotion
      enableAudio: false, // disable audio
      imageFormatGroup: ImageFormatGroup.jpeg, // image format
    );
    cameraController.initialize().then((final _) {
      if (!mounted) {
        return;
      }
      showCam = true;
      cameraInitial = true;
      setState(() {});
    });
  }

  Future<void> takePhoto() async {
    Get.defaultDialog(
      barrierDismissible: false,
      backgroundColor: Colors.white.withOpacity(0.6),
      title: '',
      middleText: '...Loading...',
      cancel: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.black,
        size: 8.h,
      ),
    );
    imageFile = await cameraController.takePicture(); // take photo from camera
    widget.onComplete(
      imageFile.path,
    );
    cameraController.pausePreview();
    Get.back();
    setState(() {
      takePhotoReady = true; // show taked image
    });
  }

  @override
  void dispose() {
    if (cameraInitial) {
      cameraController.dispose();
    } // dispose camera
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: 100.w,
        height: 100.h,
        child: !showCam
            ? const Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              )
            : takePhotoReady // show taked photo
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Image.file(
                          File(imageFile.path),
                          fit: BoxFit.contain,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Positioned(
                          // show BTN
                          bottom: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: widget.back,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 8.w,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: widget.repeat,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: const Text(
                                      'Repeat',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    cameraController.resumePreview();
                                    setState(() {
                                      takePhotoReady = false;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.repeat,
                                      size: 8.w,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: CameraPreview(
                      cameraController, // show camera
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: takePhoto,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_outlined,
                                      size: 8.w,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
