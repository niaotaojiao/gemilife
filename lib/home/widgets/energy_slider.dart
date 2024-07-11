import 'package:flutter/material.dart';

class EnergySlider extends StatefulWidget {
  final double initValue;
  final ValueChanged<double> onChanged;
  const EnergySlider(
      {super.key, required this.initValue, required this.onChanged});

  @override
  State<EnergySlider> createState() => _EnergySliderState();
}

class _EnergySliderState extends State<EnergySlider> {
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
        min: -5,
        max: 5,
        divisions: 10,
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
