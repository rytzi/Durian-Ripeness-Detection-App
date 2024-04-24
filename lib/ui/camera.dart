import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:thesis/ui/sensor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../main.dart';

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
  PageController _pageController = PageController();
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
                title: Text("Front"),
                trailing: Icon(
                  Icons.done,
                  color: pictureCount >= 1
                      ? Theme.of(context).primaryColorDark
                      : Colors.grey,),
              ),
              ListTile(
                title: Text("Left"),
                trailing: Icon(
                  Icons.done,
                  color: pictureCount >= 2
                      ? Theme.of(context).primaryColorDark
                      : Colors.grey,),
              ),
              ListTile(
                title: Text("Back"),
                trailing: Icon(
                  Icons.done,
                  color: pictureCount >= 3
                      ? Theme.of(context).primaryColorDark
                      : Colors.grey,),
              ),
              ListTile(
                title: Text("Right"),
                trailing: Icon(
                  Icons.done,
                  color: pictureCount >= 4
                      ? Theme.of(context).primaryColorDark
                      : Colors.grey,),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  for (var imageFile in imageFiles) {
                    if (imageFile != null) {
                      uploadImageToFirebase(imageFile);
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GasSensorScreen(),
                    ),
                  );
                  setState(() {
                    imageFiles.clear();
                    pictureCount = 0;
                  });
                },
                child: Text('Proceed'),
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
          );
        },
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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void openEndDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  void onTakePictureButtonPressed() {
    if (pictureCount < 4) {
      takePicture().then((XFile? file) {
        if (mounted && file != null) {
          setState(() {
            imageFiles.add(file);
            pictureCount++;
            _showPhotoPreview();
          });
        }
      });
    } else {
      openEndDrawer();
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

  void _showPhotoPreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Preview"),
          content:  Image.file(File(imageFiles[pictureCount-1]!.path)),
          actions: <Widget>[
            TextButton(
              child: Text("Retake"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  imageFiles.removeLast();
                  pictureCount--;
                });
              },
            ),
            TextButton(
              child: Text(pictureCount < 4 ? "Next" : "Confirm"),
              onPressed: () {
                if (pictureCount < 4) {
                  Navigator.of(context).pop();
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pop();
                  openEndDrawer();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showPreviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Preview"),
          content: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * .60,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: [
                for (var file in imageFiles)
                  Image.file(
                    File(file!.path),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Retake"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void uploadImageToFirebase(XFile imageFile) {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child("images").child(timestamp() + ".jpg");
    final UploadTask uploadTask = ref.putFile(File(imageFile.path));
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((url) {
        showInSnackBar("Image uploaded to Firebase: $url");
      });
    }).catchError((err) {
      showInSnackBar("Failed to upload image to Firebase: $err");
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
    final CameraController cameraController = controller;
    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
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
