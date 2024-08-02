import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemilife/home/services/event.dart';

class EditEvent extends StatefulWidget {
  final DateTime today;
  final Event event;
  final String title;
  final String? description;
  const EditEvent(
      {super.key,
      required this.today,
      required this.event,
      required this.title,
      this.description});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  late DateTime _selectedDate;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  void _editEvent() async {
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
        .doc(widget.event.id)
        .update({
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(_selectedDate),
    });

    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.today;
    _titleController.text = widget.title;
    _descController.text = widget.description!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
      ),
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
          ElevatedButton(
            onPressed: () {
              _editEvent();
            },
            child: const Text(
              "Save",
            ),
          )
        ],
      ),
    );
  }
}
