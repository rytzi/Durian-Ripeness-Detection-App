import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:thesis/ui/result.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../helper/input.dart';
import '../main.dart';
import '../widget/stencil.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<XFile?> imageFiles = [];
  int pictureCount = 0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late CameraController controller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        print('Camera Error: ' + e.code);
      }
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text('Camera'),
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
          child: Column(
            children: [
              ListTile(
                  title: Text("Side 1"),
                  leading: imageFiles.isNotEmpty && pictureCount >= 1
                      ? Image.file(
                          File(imageFiles[0]!.path),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image),
                  trailing: Icon(
                    Icons.done,
                    color: pictureCount >= 1
                        ? Theme.of(context).primaryColorDark
                        : Colors.grey,
                  ),
                  onTap: () => {
                        imageFiles.isNotEmpty && pictureCount >= 1
                            ? _showPhotoPreview(0, false)
                            : toggleEndDrawer()
                      }),
              ListTile(
                  title: Text("Side 2"),
                  leading: imageFiles.isNotEmpty && pictureCount >= 2
                      ? Image.file(
                          File(imageFiles[1]!.path),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image),
                  trailing: Icon(
                    Icons.done,
                    color: pictureCount >= 2
                        ? Theme.of(context).primaryColorDark
                        : Colors.grey,
                  ),
                  onTap: () => {
                        imageFiles.isNotEmpty && pictureCount >= 2
                            ? _showPhotoPreview(1, false)
                            : toggleEndDrawer()
                      }),
              ListTile(
                  title: Text("Side 3"),
                  leading: imageFiles.isNotEmpty && pictureCount >= 3
                      ? Image.file(
                          File(imageFiles[2]!.path),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image),
                  trailing: Icon(
                    Icons.done,
                    color: pictureCount >= 3
                        ? Theme.of(context).primaryColorDark
                        : Colors.grey,
                  ),
                  onTap: () => {
                        imageFiles.isNotEmpty && pictureCount >= 3
                            ? _showPhotoPreview(2, false)
                            : toggleEndDrawer()
                      }),
              ListTile(
                  title: Text("Side 4"),
                  leading: imageFiles.isNotEmpty && pictureCount >= 4
                      ? Image.file(
                          File(imageFiles[3]!.path),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image),
                  trailing: Icon(
                    Icons.done,
                    color: pictureCount >= 4
                        ? Theme.of(context).primaryColorDark
                        : Colors.grey,
                  ),
                  onTap: () => {
                        imageFiles.isNotEmpty && pictureCount >= 4
                            ? _showPhotoPreview(3, false)
                            : toggleEndDrawer()
                      }),
              Spacer(),
              TextButton(
                onPressed: () {
                  if (pictureCount == 4) {
                    int index = 1;
                    for (var imageFile in imageFiles) {
                      if (imageFile != null) {
                        switch (index) {
                          case 1:
                            UserInput.instance.setImage1(imageFile);
                            break;
                          case 2:
                            UserInput.instance.setImage2(imageFile);
                            break;
                          case 3:
                            UserInput.instance.setImage3(imageFile);
                            break;
                          case 4:
                            UserInput.instance.setImage4(imageFile);
                            break;
                        }
                        // uploadImageToFirebase(imageFile);
                        index++;
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResultScreen(),
                      ),
                    );
                    setState(() {
                      setFlashMode(FlashMode.off);
                      imageFiles.clear();
                      pictureCount = 0;
                    });
                  } else {
                    showInSnackBar("Needs 4 sides, only found $pictureCount");
                  }
                },
                child: Text(
                  'Proceed',
                  style: TextStyle(
                    color: pictureCount == 4
                        ? Theme.of(context).primaryColorDark
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _cameraPreviewWidget(),
            ),
          ),
          _controlRowWidget(),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    return CameraPreview(
      controller,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
              );
            },
          ),
          Center(
            child: CircularBorder(
              width: 3,
              size: MediaQuery.of(context).size.width - 10,
              color: Theme.of(context).primaryColor,
            ),
          )
        ]
      ),
    );
  }

  Widget _controlRowWidget() {
    final CameraController cameraController = controller;
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.camera_alt),
                color: Theme.of(context).primaryColorDark,
                onPressed: cameraController.value.isInitialized
                    ? onTakePictureButtonPressed
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.flash_on),
                color: Theme.of(context).primaryColorDark,
                onPressed: onFlashModeButtonPressed,
              ),
            ],
          ),
          _flashModeControlRowWidget(),
        ],
      ),
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_off),
              color: controller.value.flashMode == FlashMode.off
                  ? Theme.of(context).primaryColorDark
                  : Colors.grey,
              onPressed: () => onSetFlashModeButtonPressed(FlashMode.off),
            ),
            IconButton(
              icon: const Icon(Icons.flash_auto),
              color: controller.value.flashMode == FlashMode.auto
                  ? Theme.of(context).primaryColorDark
                  : Colors.grey,
              onPressed: () => onSetFlashModeButtonPressed(FlashMode.auto),
            ),
            IconButton(
              icon: const Icon(Icons.flash_on),
              color: controller.value.flashMode == FlashMode.always
                  ? Theme.of(context).primaryColorDark
                  : Colors.grey,
              onPressed: () => onSetFlashModeButtonPressed(FlashMode.always),
            ),
            IconButton(
              icon: const Icon(Icons.highlight),
              color: controller.value.flashMode == FlashMode.torch
                  ? Theme.of(context).primaryColorDark
                  : Colors.grey,
              onPressed: () => onSetFlashModeButtonPressed(FlashMode.torch),
            ),
          ],
        ),
      ),
    );
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void toggleEndDrawer() {
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      scaffoldKey.currentState?.openEndDrawer();
    } else {
      scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void onTakePictureButtonPressed() {
    if (pictureCount < 4) {
      takePicture().then((XFile? file) {
        if (mounted && file != null) {
          setState(() {
            imageFiles.add(file);
            _showPhotoPreview(pictureCount, true);
          });
        }
      });
    } else {
      toggleEndDrawer();
    }
  }

  Future<List<XFile?>> capturePictures(int count) async {
    List<XFile?> files = [];
    for (var i = 0; i < count; i++) {
      XFile? file = await takePicture();
      files.add(file);
    }
    return files;
  }

  void _showPhotoPreview(int index, onPictureTake) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Preview"),
          content: Image.file(File(imageFiles[index]!.path)),
          actions: <Widget>[
            TextButton(
              child: Text("Retake"),
              onPressed: () {
                if (onPictureTake) {
                  setState(() {
                    imageFiles.removeLast();
                  });
                } else {
                  setState(() {
                    imageFiles.removeAt(index);
                    pictureCount--;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(onPictureTake ? "Next" : "Confirm"),
              onPressed: () async {
                final imgInterpreter = await Interpreter.fromAsset(
                    'lib/assets/durian_detector.tflite');
                print(imgInterpreter.getInputTensors());
                if (pictureCount < 4) {
                  if (onPictureTake) {
                    setState(() {
                      pictureCount++;
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  toggleEndDrawer();
                }
              },
            ),
          ],
        );
      },
    );
  }

  String timestamp() => DateTime.now().toString();

  void uploadImageToFirebase(XFile imageFile) {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref =
        storage.ref().child("images").child("${timestamp()}.jpg");
    final UploadTask uploadTask = ref.putFile(File(imageFile.path));
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((url) {
        //TODO: WHAT TO DO WITH URL?
      });
    }).catchError((err) {
      showInSnackBar("Failed to save image");
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    showInSnackBar('Processing picture. Please wait.');
    final CameraController cameraController = controller;
    final interpreter =
    await Interpreter.fromAsset('lib/assets/durian_detector.tflite');
    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      var image = await img.decodeImageFile(file.path);
      var size = image?.width;
      var startX = 0;
      var startY = (image!.height - size!) ~/ 2;
      var croppedImage = img.copyCrop(image, x: startX, y: startY, height: size, width: size);
      var resizedImage = img.copyResize(croppedImage, width: 224, height: 224);
      var imageData = resizedImage.toUint8List();
      List<List<List<List<int>>>> result = List.generate(1, (_) =>
          List.generate(224, (_) =>
              List.generate(224, (_) =>
                  List.generate(3, (_) => 0))));
      int index = 0;
      for (int i = 0; i < 1; i++) {
        for (int j = 0; j < 224; j++) {
          for (int k = 0; k < 224; k++) {
            for (int l = 0; l < 3; l++) {
              result[i][j][k][l] = imageData[index++];
            }
          }
        }
      }
      var output = List.filled(1, List.filled(2, 0.0), growable: false);
      interpreter.run(result, output);
      print(output);
      if (output[0][0] > output[0][1]) {
        return file;
      } else {
        showInSnackBar('Our system is uncertain whether this picture contains a durian fruit. To improve accuracy, you can try retaking the picture.');
        return file;
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
