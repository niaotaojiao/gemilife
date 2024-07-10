import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemilife/home/widgets/custom_slider.dart';

class AddEvent extends StatefulWidget {
  final DateTime today;
  const AddEvent({super.key, required this.today});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late DateTime _selectedDate;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  void _addEvent() async {
    final title = _titleController.text;
    final description = _descController.text;

    if (title.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
              child: Text(
                'title cannot be empty',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser?.email;
    await FirebaseFirestore.instance
        .collection(currentUser!)
        .doc('eventlist')
        .collection('events')
        .add({
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(_selectedDate),
    });

    await FirebaseFirestore.instance
        .collection(currentUser)
        .doc('account')
        .update({
      "log_count": FieldValue.increment(1),
    });

    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          InputDatePickerFormField(
            firstDate: widget.today,
            lastDate: widget.today,
            initialDate: _selectedDate,
            onDateSubmitted: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: _titleController,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomSlider(),
          ElevatedButton(
            onPressed: () {
              _addEvent();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
