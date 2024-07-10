import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _value = 3;
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.red[700],
        inactiveTrackColor: Colors.red[100],
        trackHeight: 12.0,
        thumbColor: Colors.redAccent,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        valueIndicatorColor: Colors.red,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        overlayColor: Colors.red.withAlpha(32),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
      ),
      child: Slider(
        min: 1,
        max: 5,
        divisions: 4,
        value: _value,
        label: _value.round().toString(),
        onChanged: (value) {
          setState(() {
            _value = value;
          });
        },
      ),
    );
  }
}
