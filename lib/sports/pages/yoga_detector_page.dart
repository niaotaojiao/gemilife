import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:gemilife/sports/pages/camera_page.dart';
import 'package:gemilife/sports/services/pose_functions.dart';
import 'package:gemilife/sports/services/yoga_painter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class YogaDetectorPage extends StatefulWidget {
  final String name;
  const YogaDetectorPage({super.key, required this.name});

  @override
  State<StatefulWidget> createState() => _YogaDetectorPageState();
}

class _YogaDetectorPageState extends State<YogaDetectorPage> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.back;

  int frameCounter = 0;
  int feedbackfreq = 30;
  double percent = 0.0;
  String poseFeedback = "Please start!";

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  double _getPercent() {
    bool add = getPoseState();
    if (add && percent < 1.0) {
      percent += 0.01;
    }
    int percentInt = (percent * 1000).toInt();
    return percentInt / 1000;
  }

  void _addEvent() async {
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('events')
        .add({
      "title": 'Sport: ${widget.name}',
      "description": '${widget.name} completed today',
      "date": DateTime.now()
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
    return Positioned(
      bottom: 8.0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: LinearPercentIndicator(
          lineHeight: 20.0,
          percent: _getPercent(),
          barRadius: const Radius.circular(16),
          backgroundColor: Colors.grey,
          progressColor: Colors.blue,
        ),
      ),
    );
  }

  Widget completeText() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
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

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});
    frameCounter++;
    if (frameCounter == 3) {
      frameCounter = 0;
      final poses = await _poseDetector.processImage(inputImage);
      List<bool> poseState = poseFunctions[widget.name]!(poses);

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = YogaPainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
          poseState,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        _customPaint = null;
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
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
          bottom: 0.0, child: percent < 1.0 ? countText() : completeText()),
    ]));
  }
}
