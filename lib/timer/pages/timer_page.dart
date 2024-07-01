import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemilife/timer/services/slogans_list.dart';
import 'package:gemilife/timer/services/timer_button_state.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late Timer _timer;
  Duration duration = const Duration(minutes: 5);
  TimerButtonState currentButtonState = TimerButtonState.start;
  bool isPlaying = false;
  String slogan = SlognsList().getSlogan();
  int percent = 300;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timer.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  // Extracted the formatDuration function for reuse
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Extracted the _getButtonLabel function for reuse
  String _getButtonLabel(TimerButtonState state) {
    switch (state) {
      case TimerButtonState.start:
        return 'Start';
      case TimerButtonState.pause:
        return 'Pause';
      case TimerButtonState.resume:
        return 'Resume';
    }
  }

  void _addEvent() async {
    final currentUser = FirebaseAuth.instance.currentUser?.email;
    int minutes = percent ~/ 60;
    await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('account')
        .update({'time': FieldValue.increment(minutes)});
  }

  // Extracted the _updateTimer function for reuse
  void _updateTimer(Timer timer) {
    if (duration.inSeconds > 0) {
      setState(() {
        duration = duration - const Duration(seconds: 1);
      });
    } else {
      // Timer has reached zero
      _addEvent();
      _resetTimer();
      play();
    }
  }

  void play() async {
    try {
      await audioPlayer
          .play(AssetSource('audio/mixkit-forest-birds-singing-1212.wav'));
      print('Audio played successfully');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void pause() async {
    await audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(child: Image.asset('assets/img/m.png')),
            isPlaying ? buildTimer() : buildTimePicker(),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: const Size(100, 50),
                  ),
                  onPressed: () => _resetTimer(),
                  child:
                      Text('Cancel', style: TextStyle(color: Colors.blue[900])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: const Size(100, 50),
                  ),
                  onPressed: () => _toggleTimer(),
                  child: Text(_getButtonLabel(currentButtonState),
                      style: TextStyle(color: Colors.blue[900])),
                ),
              ],
            ),
            const SizedBox(height: 5),
            isPlaying ? const Text('') : Text(slogan),
            //const SizedBox(height: 30),
            // const Text('代辦: 這裡要做選背景音樂清單'),
          ],
        ),
      ),
    );
  }

  // Extracted the buildTimePicker function for reuse
  Widget buildTimePicker() {
    return SizedBox(
      height: 300,
      child: CupertinoTimerPicker(
        initialTimerDuration: duration,
        mode: CupertinoTimerPickerMode.ms,
        minuteInterval: 5,
        secondInterval: 1,
        onTimerDurationChanged: (newDuration) {
          if (mounted) {
            setState(() => duration = newDuration);
            percent = duration.inSeconds;
          }
        },
      ),
    );
  }

  // Extracted the buildTimer function for reuse
  Widget buildTimer() {
    return SizedBox(
      height: 300,
      child: CircularPercentIndicator(
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
        animateFromLastPercent: true,
        progressColor: Colors.blue,
        lineWidth: 20.0,
        percent: duration.inSeconds / percent,
        radius: 150.0,
        center: Text(
          formatDuration(duration),
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Extracted the _resetTimer function for reuse
  void _resetTimer() {
    setState(() {
      _timer.cancel();
      duration = const Duration(minutes: 5);
      percent = 300;
      currentButtonState = TimerButtonState.start;
      isPlaying = false;
    });
  }

  // Extracted the _toggleTimer function for reuse
  void _toggleTimer() {
    if (percent < 300) {
      // Show a message indicating that time cannot be less than five minutes
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text('Time cannot be less than five minutes!！'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK!'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        if (currentButtonState == TimerButtonState.start) {
          _timer = Timer.periodic(
            const Duration(seconds: 1),
            _updateTimer,
          );
          isPlaying = !isPlaying;
          currentButtonState = TimerButtonState.pause;
        } else if (currentButtonState == TimerButtonState.pause) {
          _timer.cancel();
          currentButtonState = TimerButtonState.resume;
        } else {
          _timer = Timer.periodic(
            const Duration(seconds: 1),
            _updateTimer,
          );
          currentButtonState = TimerButtonState.pause;
        }
      });
    }
  }
}
