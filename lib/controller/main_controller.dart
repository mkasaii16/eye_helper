import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

List cameras = [];

class MainController {
  String text = '';
  bool _isBusy = false;
  final goToCam = false.obs;
  final language = 'en-US'.obs;
  final database = 'en-US'.obs;
  GetStorage box = GetStorage();
  late ImageLabeler _imageLabeler;
  FlutterTts flutterTts = FlutterTts();

  Future<void> initialCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      if (await Permission.camera.request().isGranted) {
        cameras = await availableCameras();
      }
      await Permission.storage.request().isGranted;
    } on CameraException catch (_) {}
  }

  void initializeLabeler() async {
    const path = 'assets/ml/object_labeler.tflite';
    final modelPath = await _getModel(path);
    final options = LocalLabelerOptions(modelPath: modelPath);
    _imageLabeler = ImageLabeler(options: options);
  }

  Future<void> initialSpeaker() async {
    box = GetStorage();
    var storage = await box.read('lan');
    if (storage == null) {
      await box.write('lan', database);
    } else {
      database.value = storage;
      language.value = storage;
    }
    await flutterTts.setLanguage(database.value);
    await flutterTts.isLanguageInstalled(database.value);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(0.5);
    await flutterTts.setVolume(1.0);
  }

  Widget futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return const Text('Error loading languages...');
        } else {
          return const Text('Loading Languages...');
        }
      });

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: Obx(
        () => DropdownButton(
          value: language.value,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          dropdownColor: Colors.black,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
      ));

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  Future<void> changedLanguageDropDownItem(String? selectedType) async {
    language.value = selectedType ?? 'ar';
    box.write('lan', language.value);
    var storage = await box.read('lan');
    database.value = storage;
    flutterTts.setLanguage(language.value);
    flutterTts.isLanguageInstalled(language.value);
  }

  onTapCamera(final String path) {
    final inputImage = InputImage.fromFilePath(path);
    processImage(inputImage);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;
    final labels = await _imageLabeler.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
    } else {
      text = 'Found ${labels.length} labels.\n\n';
      for (final label in labels) {
        text += '${label.label},\n\n';
      }
      Get.snackbar('\nEyeHelper', text,
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 4),
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING);
      await flutterTts.speak(text);
    }
    _isBusy = false;
  }

  Future<void> repeatPlay() async {
    Get.snackbar('\nEyeHelper', text,
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 4),
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING);
    await flutterTts.speak(text);
  }

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
}
