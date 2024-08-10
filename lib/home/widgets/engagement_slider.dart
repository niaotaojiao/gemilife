import 'package:flutter/material.dart';

class EngagementSlider extends StatefulWidget {
  final double initValue;
  final ValueChanged<double> onChanged;
  const EngagementSlider(
      {super.key, required this.initValue, required this.onChanged});

  @override
  State<EngagementSlider> createState() => _EngagementSliderState();
}

class _EngagementSliderState extends State<EngagementSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.amber[700],
        inactiveTrackColor: Colors.amber[100],
        trackHeight: 12.0,
        thumbColor: Colors.amber,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        valueIndicatorColor: Colors.amber,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        overlayColor: Colors.red.withAlpha(32),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
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
          widget.onChanged(value);
        },
      ),
    );
  }
}
