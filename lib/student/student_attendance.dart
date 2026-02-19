import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/firebase_student.dart';

class StudentAttendance extends StatefulWidget {
  final String studentId;

  const StudentAttendance({super.key, required this.studentId});

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  final StudentFirebaseService service = StudentFirebaseService();
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget subjectAttendanceDetails({
    required String studentId,
    required String subject,
    required String sessionType,
    required StudentFirebaseService service,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Attendance",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                "$subject • $sessionType",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: service.getDetailedAttendance(
                  studentId: studentId,
                  subject: subject,
                  sessionType: sessionType,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No attendance records"));
                  }

                  final records = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final date = DateTime.parse(records[index]["date"]);
                      final present = records[index]["present"] as bool;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            present ? Icons.check_circle : Icons.cancel,
                            color: present ? Colors.green : Colors.red,
                          ),
                          title: Text("${date.day}-${date.month}-${date.year}"),
                          trailing: Text(
                            present ? "Present" : "Absent",
                            style: TextStyle(
                              color: present ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart(int perc) {
    return CircularPercentIndicator(
      radius: 40,
      lineWidth: 10,
      percent: perc / 100,
      center: Text("$perc%"),
      progressColor: perc >= 80
          ? Colors.green
          : perc >= 75
          ? Colors.orange
          : Colors.red,
      backgroundColor: Colors.grey.shade300,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget buildAttendanceCard({
    required String subject,
    required String type,
    required int total,
    required int present,
  }) {
    final absent = total - present;
    final perc = total == 0 ? 0 : ((present / total) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 0.2),
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 236, 250, 255),
        boxShadow: const [
          BoxShadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.grey),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Subject row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return subjectAttendanceDetails(
                        studentId: widget.studentId,
                        subject: subject,
                        sessionType: type,
                        service: service,
                      );
                    },
                  );
                },
                child: Text("View All", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Spacer(),
              buildChart(perc),
              const Spacer(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legend(Colors.grey, "Total : $total"),
                  _legend(Colors.green, "Present : $present"),
                  _legend(Colors.redAccent, "Absent : $absent"),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "View Attendance",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                controller: searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Subject Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            FutureBuilder<Map<String, Map<String, int>>>(
              future: service.getSubjectTypeAttendanceStats(widget.studentId),
              builder: (context, snapshot) {
                final data = snapshot.data!;

                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No attendance found"),
                  );
                }
                final filteredEntries = data.entries.where((e) {
                  final key = e.key.toLowerCase();
                  return key.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredEntries.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "No matching records found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filteredEntries.map((e) {
                    final parts = e.key.split(" | ");
                    final subject = parts[0];
                    final type = parts[1];

                    return buildAttendanceCard(
                      subject: subject,
                      type: type,
                      total: e.value["total"]!,
                      present: e.value["present"]!,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
