import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vioguard/dashboard.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ViolationScreen(
        name: "John Doe",
        course: "Computer Science",
        studentNo: "2021001",
        violationsCount: 2,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ViolationScreen extends StatefulWidget {
  final String name;
  final String course;
  final String studentNo;
  final int violationsCount;

  const ViolationScreen({
    super.key,
    required this.name,
    required this.course,
    required this.studentNo,
    this.violationsCount = 0,
  });

  @override
  State<ViolationScreen> createState() => _ViolationScreenState();
}

class _ViolationScreenState extends State<ViolationScreen> {
  late final TextEditingController fullNameController;
  late final TextEditingController studentNumberController;
  late final TextEditingController courseController;

  int violations = 0;
  File? _evidenceImage;
  String searchQuery = "";
  final Set<String> selectedViolations = {};

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

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.name);
    studentNumberController = TextEditingController(text: widget.studentNo);
    courseController = TextEditingController(text: widget.course);
    violations = widget.violationsCount;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    studentNumberController.dispose();
    courseController.dispose();
    super.dispose();
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _evidenceImage = File(pickedFile.path));
    }
  }

  /// Show success popup then redirect
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                radius: 40,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Violation Recorded!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Redirecting...",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );

    /// Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SchoolGuardHome()),
        );
      }
    });
  }

  /// Show confirmation dialog before submitting
  void _showConfirmationDialog() {
    // Validate student info
    if (fullNameController.text.trim().isEmpty ||
        studentNumberController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please fill in all student information."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate violation selection
    if (selectedViolations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select at least one violation."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show confirmation dialog if validations pass
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Violation Record"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("👤 Name: ${fullNameController.text}"),
              Text("🎓 Course: ${courseController.text}"),
              Text("🆔 Student No: ${studentNumberController.text}"),
              const SizedBox(height: 10),
              const Text(
                "Selected Violations:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: selectedViolations.map((v) => Text("• $v")).toList(),
              ),
              const SizedBox(height: 10),
              if (_evidenceImage != null)
                const Text(
                  "📷 Evidence attached",
                  style: TextStyle(color: Colors.green),
                )
              else
                const Text(
                  "📷 No evidence",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Edit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close confirmation
              _showSuccessDialog(); // show success popup & redirect
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredViolations = violationTypes
        .where((v) => v.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Violation"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildStudentInfoCard(),
              const SizedBox(height: 15),
              _buildViolationTypesCard(filteredViolations),
              const SizedBox(height: 15),
              _buildEvidenceUploader(),
              if (_evidenceImage != null) _buildEvidencePreview(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Student Information Card
  Widget _buildStudentInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Student Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(fullNameController, "Full Name"),
            _buildTextField(studentNumberController, "Student Number"),
            _buildTextField(courseController, "Course"),
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
    );
  }

  /// Violation Types Card
  Widget _buildViolationTypesCard(List<String> filteredViolations) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Violation Types",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Search Violation",
                prefixIcon: Icon(Icons.search),
                border: UnderlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemCount: filteredViolations.length,
              itemBuilder: (_, index) {
                final violation = filteredViolations[index];
                final isSelected = selectedViolations.contains(violation);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? selectedViolations.remove(violation)
                          : selectedViolations.add(violation);
                      violations = selectedViolations.length;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      violation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Upload Evidence Button
  Widget _buildEvidenceUploader() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.camera_alt),
      label: const Text("Attach photo evidence (optional)"),
    );
  }

  /// Evidence Preview with Remove Button
  Widget _buildEvidencePreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _evidenceImage!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() => _evidenceImage = null);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cancel / Record Buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(150, 70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _showConfirmationDialog, // <-- validation + confirmation
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size(150, 70),
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
    );
  }

  /// Helper TextField
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
