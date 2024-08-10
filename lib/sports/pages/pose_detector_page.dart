import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:gemilife/sports/pages/camera_page.dart';
import 'package:gemilife/sports/services/pose_functions.dart';
import 'package:gemilife/sports/services/pose_painter.dart';

class PoseDetectorPage extends StatefulWidget {
  final String name;
  const PoseDetectorPage({super.key, required this.name});

  @override
  State<StatefulWidget> createState() => _PoseDetectorPageState();
}

class _PoseDetectorPageState extends State<PoseDetectorPage> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.back;

  int frameCounter = 0;
  int counter = 0;
  bool poseState = false;

  @override
  void dispose() async {
    resetCount();
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  void _addEvent() async {
    final DateTime now = DateTime.now();
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('sports')
        .add({
      "name": widget.name,
      "date": DateTime(now.year, now.month, now.day),
    });

    await FirebaseFirestore.instance
        .collection(currentUser)
        .doc('account')
        .update({
      "activity_count": FieldValue.increment(1),
    });

    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }

  Widget countText() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.blue[900],
      child: Text(
        'Count: $counter',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget completeText() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.green,
      child: Column(
        children: [
          const Text(
            'Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _addEvent();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        CameraView(
          customPaint: _customPaint,
          onImage: _processImage,
          poseName: widget.name,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        Positioned(
          bottom: 0.0,
          child: counter < 10 ? countText() : completeText(),
        )
      ]),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});
    frameCounter++;
    if (frameCounter == 3) {
      frameCounter = 0;
      final poses = await _poseDetector.processImage(inputImage);
      poseState = poseFunctions[widget.name]!(poses, poseState);
      counter = getCount();

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        // TODO: set _customPaint to draw landmarks on top of image
        _customPaint = null;
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
