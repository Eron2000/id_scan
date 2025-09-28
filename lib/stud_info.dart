import 'package:flutter/material.dart';
import 'package:app/dashboard.dart';

void main() {
  runApp(const ViolationApp());
}

class ViolationApp extends StatelessWidget {
  const ViolationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ViolationScreen(
        fullname: "John Doe",
        studentNo: "123456",
        course: "BSIT",
        violationsCount: 0,
      ), // ✅ For testing, you can replace with scanner navigation
    );
  }
}

class ViolationScreen extends StatefulWidget {
  final String fullname;
  final String studentNo;
  final String course;
  final int violationsCount;

  const ViolationScreen({
    super.key,
    required this.fullname,
    required this.studentNo,
    required this.course,
    required this.violationsCount,
  });

  @override
  _ViolationScreenState createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  late TextEditingController fullNameController;
  late TextEditingController studentNumberController;
  late TextEditingController courseController;

  int violations = 0;

  // Violation Types
  final List<String> violationTypes = [
    "Dress Code",
    "Noise Disturbance",
    "Late Attendance",
    "ID not Displayed",
    "Serious Misconduct",
    "Smoking on Campus",
    "Vandalism",
    "Others",
  ];

  String searchQuery = "";
  Set<String> selectedViolations = {};

  @override
  void initState() {
    super.initState();

    // Pre-fill from scanner
    fullNameController = TextEditingController(text: widget.fullname);
    studentNumberController = TextEditingController(text: widget.studentNo);
    courseController = TextEditingController(text: widget.course);

    violations = widget.violationsCount;
  }

  @override
  Widget build(BuildContext context) {
    final filteredViolations = violationTypes
        .where((v) => v.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Student Information (inside Card)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Student Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          border: UnderlineInputBorder(), // ✅ line only
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: studentNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Student Number",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: courseController,
                        decoration: const InputDecoration(
                          labelText: "Course",
                          border: UnderlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        "Violations: $violations",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Violation Types (inside Card)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Violation Types",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Search Violation",
                          prefixIcon: Icon(Icons.search),
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 per row
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3.5,
                            ),
                        itemCount: filteredViolations.length,
                        itemBuilder: (context, index) {
                          final violation = filteredViolations[index];
                          final isSelected = selectedViolations.contains(
                            violation,
                          );

                          return ChoiceChip(
                            label: Text(violation),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedViolations.add(violation);
                                } else {
                                  selectedViolations.remove(violation);
                                }
                                violations = selectedViolations.length;
                              });
                            },
                            selectedColor: Colors.blueAccent,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: photo picker
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Attach photo evidence (optional)"),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String name = fullNameController.text;
                      String id = studentNumberController.text;
                      String course = courseController.text;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Recorded for $name ($id, $course): ${selectedViolations.join(", ")}",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Record Violation",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
