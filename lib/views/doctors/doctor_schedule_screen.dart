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

    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ✅ HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F7B8E),
                      Color(0xFF14919B),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const SizedBox(width: 10),

                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Availability",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Set your working schedule",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ✅ MAIN CARD
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ✅ DAYS
                    const Text(
                      "Working Days",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: days.map((day) {

                        final selected =
                            selectedDays.contains(day);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            });
                          },

                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF0F7B8E)
                                  : Colors.grey[100],

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            child: Text(
                              day,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );

                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // ✅ TIME SECTION
                    const Text(
                      "Working Hours",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Expanded(
                          child: _timeCard(
                            context,
                            "Start",
                            startTime,
                            Icons.login,
                            () async {

                              final picked =
                                  await showTimePicker(
                                context: context,
                                initialTime:
                                    const TimeOfDay(
                                  hour: 8,
                                  minute: 0,
                                ),
                              );

                              if (picked != null) {
                                setState(
                                  () => startTime = picked,
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: _timeCard(
                            context,
                            "End",
                            endTime,
                            Icons.logout,
                            () async {

                              final picked =
                                  await showTimePicker(
                                context: context,
                                initialTime:
                                    const TimeOfDay(
                                  hour: 17,
                                  minute: 0,
                                ),
                              );

                              if (picked != null) {
                                setState(
                                  () => endTime = picked,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // ✅ SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0F7B8E),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                        ),

                        onPressed: () async {

                          print("Doctor UID = $doctorId");

                          if (selectedDays.isEmpty ||
                              startTime == null ||
                              endTime == null) {

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please complete all fields"),
                              ),
                            );
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection('schedules')
                              .doc(doctorId) // ✅ UNIQUE PER DOCTOR
                              .set({

                            'doctorId': doctorId,
                            'days': selectedDays,
                            'start': startTime!
                                .format(context),
                            'end': endTime!
                                .format(context),

                          });

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Schedule saved ✅")),
                          );

                          Navigator.pop(context);
                        },

                        child: const Text(
                          "Save Schedule",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ TIME CARD
  Widget _timeCard(
    BuildContext context,
    String label,
    TimeOfDay? time,
    IconData icon,
    VoidCallback onTap,
  ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: const Color(0xFF0F7B8E)),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              time == null
                  ? "Select"
                  : time.format(context),

              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
