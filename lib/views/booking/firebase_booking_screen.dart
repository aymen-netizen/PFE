import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../appointments/patient_request_form.dart';

class FirebaseBookingScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const FirebaseBookingScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<FirebaseBookingScreen> createState() =>
      _FirebaseBookingScreenState();
}

class _FirebaseBookingScreenState
    extends State<FirebaseBookingScreen> {

  DateTime? selectedDate;
  String? selectedTime;

  List<String> availableDays = [];

  @override
  Widget build(BuildContext context) {

    final doctorId = widget.doctor['uid'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .doc(doctorId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No schedule"));
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          availableDays =
              List<String>.from(data['days']);

          final start = data['start'];
          final end = data['end'];

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // ✅ HEADER (same)
                  Container(
                    height: 320,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0F7B8E),
                          Color(0xFF14919B),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [

                        Positioned(
                          left: 20,
                          top: 20,
                          child: CircleAvatar(
                            backgroundColor:
                                Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () =>
                                  Navigator.pop(context),
                            ),
                          ),
                        ),

                        Center(
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage:
                                const AssetImage(
                                    "assets/doctors/doctor1.jpg"),
                          ),
                        ),

                        Positioned(
                          bottom: 25,
                          left: 25,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctor['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: const [
                                  Text("Cardiologue",
                                      style: TextStyle(
                                          color:
                                              Colors.white70)),
                                  SizedBox(width: 8),
                                  Icon(Icons.star,
                                      color: Colors.amber,
                                      size: 16),
                                  Text(" 4.8",
                                      style: TextStyle(
                                          color:
                                              Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          bottom: 25,
                          right: 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.phone,
                                  color: Color(0xFF0F7B8E)),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ STATS
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _Stat("8 years", "Experience"),
                        _Stat("2.7K+", "Patients"),
                        _Stat("4.8", "Reviews"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ DATE + TIME
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // ✅ DATE CARD
                        const Text(
                          "Select Date",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: () async {

                            final picked =
                                await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now(),
                              firstDate:
                                  DateTime.now(),
                              lastDate:
                                  DateTime(2030),
                            );

                            if (picked != null) {

                              final dayName = [
                                'Monday','Tuesday','Wednesday',
                                'Thursday','Friday','Saturday','Sunday'
                              ][picked.weekday - 1];

                              if (!availableDays
                                  .contains(dayName)) {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Doctor not available this day"),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },

                          child: _selectionCard(
                            icon: Icons.calendar_month,
                            text: selectedDate == null
                                ? "Select a date"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ✅ TIME CARD
                        const Text(
                          "Select Time",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: () async {

                            if (selectedDate == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Select date first"),
                                ),
                              );
                              return;
                            }

                            final picked =
                                await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.now(),
                            );

                            if (picked != null) {

                              if (!isTimeAllowed(
                                  picked, start, end)) {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Outside working hours"),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                selectedTime =
                                    picked.format(context);
                              });
                            }
                          },

                          child: _selectionCard(
                            icon: Icons.access_time,
                            text: selectedTime ??
                                "Select a time",
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ✅ BOOK
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF0F7B8E),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        30),
                              ),
                            ),
                            onPressed:
                                selectedDate == null ||
                                        selectedTime == null
                                    ? null
                                    : () {

                                        final formattedDate =
                                            "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PatientRequestForm(
                                              doctorId:
                                                  doctorId,
                                              doctorName:
                                                  widget.doctor[
                                                      'name'],
                                              specialty:
                                                  widget.doctor[
                                                      'specialty'],
                                              selectedDate:
                                                  formattedDate,
                                              selectedTime:
                                                  selectedTime!,
                                            ),
                                          ),
                                        );
                                      },
                            child: const Text(
                              "Book Appointment - 50 DT",
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ ✅ NICE CARD WIDGET
  Widget _selectionCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [

          Icon(icon, color: const Color(0xFF0F7B8E)),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  bool isTimeAllowed(
    TimeOfDay picked,
    String start,
    String end,
  ) {

    TimeOfDay parse(String time) {
      final parts = time.split(" ");
      final hm = parts[0].split(":");

      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);

      if (parts[1] == "PM" && hour != 12) hour += 12;
      if (parts[1] == "AM" && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    }

    final startTime = parse(start);
    final endTime = parse(end);

    int pickedMin = picked.hour * 60 + picked.minute;
    int startMin = startTime.hour * 60 + startTime.minute;
    int endMin = endTime.hour * 60 + endTime.minute;

    return pickedMin >= startMin &&
        pickedMin <= endMin;
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}