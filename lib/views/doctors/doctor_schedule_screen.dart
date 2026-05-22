import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() =>
      _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState
    extends State<DoctorScheduleScreen> {

  List<String> selectedDays = [];

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const Text("Select Working Days"),

            Wrap(
              spacing: 8,
              children: days.map((day) {

                final selected = selectedDays.contains(day);

                return ChoiceChip(
                  label: Text(day),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        selectedDays.remove(day);
                      } else {
                        selectedDays.add(day);
                      }
                    });
                  },
                );

              }).toList(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 8, minute: 0),
                );

                if (picked != null) {
                  setState(() => startTime = picked);
                }
              },
              child: Text(
                startTime == null
                    ? "Start Time"
                    : startTime!.format(context),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 17, minute: 0),
                );

                if (picked != null) {
                  setState(() => endTime = picked);
                }
              },
              child: Text(
                endTime == null
                    ? "End Time"
                    : endTime!.format(context),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                await FirebaseFirestore.instance
                    .collection('schedules')
                    .doc(uid)
                    .set({

                  'days': selectedDays,
                  'start': startTime?.format(context),
                  'end': endTime?.format(context),

                });

                Navigator.pop(context);
              },
              child: const Text("Save Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}
