import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

Map<String, dynamic> poseFunctions = {
  'Push-up': pushup,
  'Sit-up': situp,
  'Squat': squat,
  'Warrior-1': warriorPose1,
  'Warrior-2': warriorPose2,
  'Tree Pose': treePose,
};

int count = 0;

List<bool> yogaPoseState = List<bool>.filled(8, false);

void resetCount() {
  count = 0;
}

void initYogaPoseState() {
  yogaPoseState = List<bool>.filled(8, false);
}

double angle(PoseLandmark firstLandmark, PoseLandmark midLandmark,
    PoseLandmark lastLandmark) {
  final radians = math.atan2(
          lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
      math.atan2(
          firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);
  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs();
  if (degrees > 180.0) {
    degrees = 360.0 - degrees;
  }
  return degrees;
}

int getCount() {
  return count;
}

bool getPoseState() {
  return yogaPoseState.every((bool pose) => pose == true) ? true : false;
}

bool pushup(List<Pose> poses, bool poseState) {
  const double down = 100.0;
  const double up = 140.0;
  try {
    final leftElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftWrist]!);
    final rightElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightWrist]!);
    if (rightElbowAngle > up) {
      poseState = true;
    } else if (rightElbowAngle < down && poseState) {
      count++;
      poseState = false;
    }
  } catch (e) {
    print(e);
  }
  return poseState;
}

bool situp(List<Pose> poses, bool poseState) {
  const double down = 75.0;
  const double up = 115.0;
  try {
    final leftElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftWrist]!);
    final rightHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!);

    if (rightHipAngle > up) {
      poseState = true;
    } else if (rightHipAngle < down && poseState) {
      count++;
      poseState = false;
    }
  } catch (e) {
    print(e);
  }
  return poseState;
}

bool squat(List<Pose> poses, bool poseState) {
  const double down = 100.0;
  const double up = 140.0;
  try {
    final rightKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!,
        poses[0].landmarks[PoseLandmarkType.rightAnkle]!);

    if (rightKneeAngle > up) {
      poseState = true;
    } else if (rightKneeAngle < down && poseState) {
      count++;
      poseState = false;
    }
  } catch (e) {
    print(e);
  }
  return poseState;
}

List<bool> warriorPose2(List<Pose> poses) {
  initYogaPoseState();
  try {
    final leftElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftWrist]!,
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!);
    final leftShoulderAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftHip]!);
    final leftHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftHip]!,
        poses[0].landmarks[PoseLandmarkType.leftKnee]!);
    final leftKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftHip]!,
        poses[0].landmarks[PoseLandmarkType.leftKnee]!,
        poses[0].landmarks[PoseLandmarkType.leftAnkle]!);
    final rightElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightWrist]!,
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!);
    final rightShoulderAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!);
    final rightHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!);
    final rightKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!,
        poses[0].landmarks[PoseLandmarkType.rightAnkle]!);

    if (leftElbowAngle > 165.0) {
      yogaPoseState[0] = true;
    }
    if (leftShoulderAngle > 75.0 && leftShoulderAngle < 105.0) {
      yogaPoseState[1] = true;
    }
    if (leftHipAngle > 70.0 && leftHipAngle < 120.0) {
      yogaPoseState[2] = true;
    }
    if (leftKneeAngle > 70.0 && leftKneeAngle < 120.0) {
      yogaPoseState[3] = true;
    }
    if (rightElbowAngle > 165.0) {
      yogaPoseState[4] = true;
    }
    if (rightShoulderAngle > 75.0 && rightShoulderAngle < 105.0) {
      yogaPoseState[5] = true;
    }
    if (rightHipAngle > 115 && rightHipAngle < 155) {
      yogaPoseState[6] = true;
    }
    if (rightKneeAngle > 155.0) {
      yogaPoseState[7] = true;
    }
  } catch (e) {
    print('Error: $e');
  }
  return yogaPoseState;
}

List<bool> warriorPose1(List<Pose> poses) {
  initYogaPoseState();
  try {
    final leftElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftWrist]!,
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!);
    final leftShoulderAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftHip]!);
    final leftHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftHip]!,
        poses[0].landmarks[PoseLandmarkType.leftKnee]!);
    final leftKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftHip]!,
        poses[0].landmarks[PoseLandmarkType.leftKnee]!,
        poses[0].landmarks[PoseLandmarkType.leftAnkle]!);
    final rightElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightWrist]!,
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!);
    final rightShoulderAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!);
    final rightHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!);
    final rightKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!,
        poses[0].landmarks[PoseLandmarkType.rightAnkle]!);

    if (leftElbowAngle > 155.0) {
      yogaPoseState[0] = true;
    }
    if (leftShoulderAngle > 140.0) {
      yogaPoseState[1] = true;
    }
    if (leftHipAngle > 80.0 && leftHipAngle < 100.0) {
      yogaPoseState[2] = true;
    }
    if (leftKneeAngle > 70.0 && leftKneeAngle < 120.0) {
      yogaPoseState[3] = true;
    }
    if (rightElbowAngle > 155.0) {
      yogaPoseState[4] = true;
    }
    if (rightShoulderAngle > 140.0) {
      yogaPoseState[5] = true;
    }
    if (rightHipAngle > 120.0 && rightHipAngle < 150.0) {
      yogaPoseState[6] = true;
    }
    if (rightKneeAngle > 155.0) {
      yogaPoseState[7] = true;
    }
  } catch (e) {
    print('Error: $e');
  }
  return yogaPoseState;
}

List<bool> treePose(List<Pose> poses) {
  initYogaPoseState();
  try {
    final leftElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftWrist]!,
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!);
    final leftShoulderAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftElbow]!,
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftHip]!);
    final leftHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftShoulder]!,
        poses[0].landmarks[PoseLandmarkType.leftHip]!,
        poses[0].landmarks[PoseLandmarkType.leftKnee]!);
    final leftKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.leftHip]!,
        poses[0].landmarks[PoseLandmarkType.leftKnee]!,
        poses[0].landmarks[PoseLandmarkType.leftAnkle]!);
    final rightElbowAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightWrist]!,
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!);
    final rightShoulderAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightElbow]!,
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!);
    final rightHipAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightShoulder]!,
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!);
    final rightKneeAngle = angle(
        poses[0].landmarks[PoseLandmarkType.rightHip]!,
        poses[0].landmarks[PoseLandmarkType.rightKnee]!,
        poses[0].landmarks[PoseLandmarkType.rightAnkle]!);

    if (leftElbowAngle < 65.0) {
      yogaPoseState[0] = true;
    }
    if (leftShoulderAngle < 45.0) {
      yogaPoseState[1] = true;
    }
    if (leftHipAngle > 160.0) {
      yogaPoseState[2] = true;
    }
    if (leftKneeAngle > 160.0) {
      yogaPoseState[3] = true;
    }
    if (rightElbowAngle < 65.0) {
      yogaPoseState[4] = true;
    }
    if (rightShoulderAngle < 45.0) {
      yogaPoseState[5] = true;
    }
    if (rightHipAngle > 80.0) {
      yogaPoseState[6] = true;
    }
    if (rightKneeAngle < 90.0) {
      yogaPoseState[7] = true;
    }
  } catch (e) {
    print('Error: $e');
  }
  return yogaPoseState;
}
