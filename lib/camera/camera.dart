// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groupchat_firebase/models/post.dart';
import 'package:groupchat_firebase/models/user.dart';
import 'package:groupchat_firebase/pages/tag_friends.dart';
import 'package:groupchat_firebase/state/auth_state.dart';
import 'package:image/image.dart' as img;
import 'package:groupchat_firebase/state/groupchatState.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/groupchat.dart';
import '../pages/group_screen.dart';

class CameraPage extends StatefulWidget {
  final GroupChat groupChat;

  const CameraPage(
      {Key? key,
      this.text,
      this.initialDirection = CameraLensDirection.back,
      required this.groupChat})
      : super(key: key);

  final String? text;
  final CameraLensDirection initialDirection;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  CameraController? _controller;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  int _cameraIndex = -1;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  bool _changingCameraLens = false;
  bool flashEnabled = false;
  String frontImagePath = "";
  String backImagePath = "";
  bool isFrontImageTaken = false;
  bool isBackImageTaken = false;
  AnimationController? rotationController;
  final Duration animationDuration = const Duration(milliseconds: 1000);
  String firstImagePath = "";
  bool isFirstImageTaken = false;

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    // _stopLiveFeed();
    super.dispose();
  }

  Future<String> uploadImageToStorage(File file) async {
    String fileName = Path.basename(file.path);
    Reference storageRef = _storage.ref().child('images/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> addPostToDatabase(PostModel post) async {
    var newPostRef = _databaseRef.child('posts').child(post.key!).push();
    newPostRef.set(post.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      GroupScreen(groupChat: widget.groupChat),
                  transitionDuration: Duration(seconds: 1),
                  transitionsBuilder: (context, animation, animation2, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 35,
            ),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 78,
        elevation: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Image.asset(
                "assets/logo/logo.png",
                height: 35,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() {
    double aspectRatio;
    try {
      aspectRatio = _controller?.value.aspectRatio ?? 1.0;
    } catch (e) {
      aspectRatio = 1.0;
    }
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // positive value means downward drag
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  GroupScreen(groupChat: widget.groupChat),
              transitionDuration: Duration(seconds: 1),
              transitionsBuilder: (context, animation, animation2, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: isFirstImageTaken
          ? Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.63,
                  width: MediaQuery.of(context).size.width / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Image.file(
                        File(firstImagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _controller != null && _controller!.value.isInitialized
              ? Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: Colors.black,
                        height: MediaQuery.of(context).size.height / 1.63,
                        width: MediaQuery.of(context).size.width / 1,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.previewSize!.height,
                            height: _controller!.value.previewSize!.width,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _flashEnable,
                          child: Icon(
                            flashEnabled
                                ? Iconsax.flash_15
                                : Iconsax.flash_slash5,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        Container(
                          width: 25,
                        ),
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Container(
                          width: 25,
                        ),
                        GestureDetector(
                          onTap: _switchFrontCamera,
                          child: AnimatedBuilder(
                            animation: rotationController!,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: rotationController!.value * 2.0 * pi,
                                child: child,
                              );
                            },
                            child: Transform(
                              transform: Matrix4.identity()
                                ..scale(-1.0, 1.0, -1.0),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.loop_rounded,
                                color: Colors.white,
                                size: 37,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      if (flashEnabled) {
        _controller!.setFlashMode(FlashMode.always);
      } else {
        _controller!.setFlashMode(FlashMode.off);
      }
      setState(() {});
    });
  }

  Future<void> _takePicture() async {
    HapticFeedback.heavyImpact();
    var state = Provider.of<AuthState>(context, listen: false);

    // Take the first picture
    XFile firstPicture = await _controller!.takePicture();

    // If the image is taken with the front camera, flip it
    if (_cameraIndex == 1) {
      final image = img.decodeImage(File(firstPicture.path).readAsBytesSync());
      final flippedImage =
          img.flip(image!, direction: img.FlipDirection.horizontal);
      File(firstPicture.path)..writeAsBytesSync(img.encodePng(flippedImage));
    }

    // Immediately update the UI to show the first image
    setState(() {
      firstImagePath = firstPicture.path; // Update class-level variable
      isFirstImageTaken = true;
    });

    // Upload the first image to Firebase Storage
    String uploadedFirstImagePath =
        await uploadImageToStorage(File(firstPicture.path));

    // Switch the camera lens
    await _switchFrontCamera();

    // Wait for a moment before taking the second picture
    await Future.delayed(Duration(milliseconds: 400));

    // Take the second picture
    XFile secondPicture = await _controller!.takePicture();

    // If the image is taken with the front camera, flip it
    if (_cameraIndex == 1) {
      final image = img.decodeImage(File(secondPicture.path).readAsBytesSync());
      final flippedImage =
          img.flip(image!, direction: img.FlipDirection.horizontal);
      File(secondPicture.path)..writeAsBytesSync(img.encodePng(flippedImage));
    }

    // Upload the second image to Firebase Storage
    String uploadedSecondImagePath =
        await uploadImageToStorage(File(secondPicture.path));

    // Determine which image is front and which is back based on the camera index
    String imageFrontPath =
        _cameraIndex == 0 ? uploadedFirstImagePath : uploadedSecondImagePath;
    String imageBackPath =
        _cameraIndex == 0 ? uploadedSecondImagePath : uploadedFirstImagePath;

    UserModel user = UserModel(
      displayName: state.profileUserModel!.displayName ?? "",
      profilePic: state.profileUserModel!.profilePic,
      userId: state.profileUserModel!.userId,
      userName: state.profileUserModel!.userName,
      fcmToken: state.profileUserModel!.fcmToken,
      localisation: state.profileUserModel!.localisation,
    );

    // Create and add the post to the database
    PostModel post = PostModel(
      user: user,
      imageFrontPath: imageFrontPath,
      imageBackPath: imageBackPath,
      createdAt: DateTime.now().toUtc().toString(),
      key: widget.groupChat.key,
      groupChat: widget.groupChat,
    );

    // Navigate back to the previous page after both images are taken and uploaded
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => TagFriends(postModel: post)),
    );
  }

  Future _stopLiveFeed() async {
    _controller = null;
  }

  Future _flashEnable() async {
    HapticFeedback.heavyImpact();
    setState(() {
      flashEnabled = !flashEnabled;
    });
    print("Flash Enabled: $flashEnabled");
    if (flashEnabled) {
      _controller!.setFlashMode(FlashMode.always);
    } else {
      _controller!.setFlashMode(FlashMode.off);
    }
  }

  Future _switchGiantAngle() async {
    HapticFeedback.heavyImpact();
    if (_cameraIndex == 2) {
      setState(() => _changingCameraLens = true);
      _cameraIndex = 0;
      await _stopLiveFeed();
      await _startLiveFeed();
      setState(() => _changingCameraLens = false);
    } else {
      setState(() => _changingCameraLens = true);
      _cameraIndex = 2;

      await _stopLiveFeed();
      await _startLiveFeed();
      setState(() => _changingCameraLens = false);
    }
  }

  Future _switchFrontCamera() async {
    print("Switching camera");
    HapticFeedback.heavyImpact();
    setState(() => _changingCameraLens = true);
    if (_cameraIndex == 0 || _cameraIndex == 2) {
      _cameraIndex = 1;
    } else {
      _cameraIndex = 0;
    }

    await _stopLiveFeed();
    await _startLiveFeed();

    // Set flash mode based on flashEnabled state
    if (flashEnabled) {
      _controller!.setFlashMode(FlashMode.always);
    } else {
      _controller!.setFlashMode(FlashMode.off);
    }

    setState(() => _changingCameraLens = false);
    rotationController!.forward();
    rotationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        rotationController!.reset();
      }
    });
  }

  void _processCameraImage(CameraImage image) {}
}
