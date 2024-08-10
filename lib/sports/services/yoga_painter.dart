import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class YogaPainter extends CustomPainter {
  YogaPainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.poseState,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final List<bool> poseState;

  @override
  void paint(Canvas canvas, Size size) {
    final initPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.redAccent;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    for (final pose in poses) {
      /*pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            1,
            paint);
      });*/

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(
                translateX(
                  joint1.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint1.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            Offset(
                translateX(
                  joint2.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint2.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            paintType);
      }

      if (poseState[0] && poseState[1] && poseState[4] && poseState[5]) {
        paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
            rightPaint);
      } else {
        paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
            initPaint);
      }

      if (poseState[2] && poseState[3] && poseState[6] && poseState[7]) {
        paintLine(
            PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, rightPaint);
      } else {
        paintLine(
            PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, initPaint);
      }

      if (poseState[0] && poseState[1]) {
        paintLine(
            PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow, rightPaint);
        paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder,
            rightPaint);
        paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip,
            rightPaint);
      } else {
        paintLine(
            PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow, initPaint);
        paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder,
            initPaint);
        paintLine(
            PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, initPaint);
      }

      if (poseState[2] && poseState[3]) {
        paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip,
            rightPaint);
        paintLine(
            PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, rightPaint);
        paintLine(
            PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, rightPaint);
      } else {
        paintLine(
            PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, initPaint);
        paintLine(
            PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, initPaint);
        paintLine(
            PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, initPaint);
      }

      if (poseState[4] && poseState[5]) {
        paintLine(PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow,
            rightPaint);
        paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder,
            rightPaint);
        paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
            rightPaint);
      } else {
        paintLine(PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow,
            initPaint);
        paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder,
            initPaint);
        paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
            initPaint);
      }

      if (poseState[6] && poseState[7]) {
        paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
            rightPaint);
        paintLine(
            PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
        paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle,
            rightPaint);
      } else {
        paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
            initPaint);
        paintLine(
            PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, initPaint);
        paintLine(
            PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, initPaint);
      }

/*
      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, initPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, initPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          initPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, initPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, initPaint);
      paintLine(
          PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, initPaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
          initPaint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, initPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, initPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, initPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, initPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, initPaint);
  */
    }
  }

  @override
  bool shouldRepaint(covariant YogaPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
