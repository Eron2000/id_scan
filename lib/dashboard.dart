import 'package:flutter/material.dart';
import 'package:vioguard/id_scanner.dart';
import 'package:vioguard/login.dart';

class SchoolGuardHome extends StatefulWidget {
  const SchoolGuardHome({super.key});

  @override
  State<SchoolGuardHome> createState() => _SchoolGuardHomeState();
}

class _SchoolGuardHomeState extends State<SchoolGuardHome> {
  final List<Map<String, String>> scanData = [
    {
      "name": "Annie Batumbakal",
      "id": "202205249",
      "offense": "1st",
      "violation": "Academic Dishonesty",
      "department": "College of Arts & Sciences",
      "time": "2025-09-09 10:00",
    },
    {
      "name": "Juan Dela Cruz",
      "id": "202205232",
      "offense": "2nd",
      "violation": "Improper Uniform",
      "department": "College of Computer Studies",
      "time": "2025-09-09 11:30",
    },
    {
      "name": "James Reid",
      "id": "202205211",
      "offense": "3rd",
      "violation": "Serious Misconduct",
      "department": "College of Education",
      "time": "2025-09-08 09:00",
    },
    {
      "name": "Sponge Cola",
      "id": "202209211",
      "offense": "1st",
      "violation": "Late Attendance",
      "department": "College of Criminology",
      "time": "2025-09-07 14:15",
    },
    {
      "name": "Maria Santos",
      "id": "202205299",
      "offense": "2nd",
      "violation": "Improper Conduct",
      "department": "College of Business Administration",
      "time": "2025-09-06 16:45",
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredData = scanData
        .where(
          (scan) =>
              scan["id"]!.contains(searchQuery) ||
              scan["name"]!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildScannerCard(),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search student ID or name...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
              ),
              const SizedBox(height: 20),
              _buildRecentScans(filteredData),
              const SizedBox(height: 16),
              _buildViewAllButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/logo.png'),
                color: Colors.white,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Safety and Security Office\nCMU - DRMS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("47", "Students Scanned"),
              Container(height: 40, width: 1, color: Colors.white24),
              _statBox("12", "Violations Today"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildScannerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.indigo.shade600),
          const SizedBox(height: 12),
          const Text(
            "Ready to Scan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            "Position the student ID card in front of the camera",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentIDScannerApp(),
                ),
              );
              if (result != null && result is Map<String, String>) {
                setState(() => scanData.insert(0, result));
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Start Scan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans(List<Map<String, String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Scans",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...data.take(3).map((scan) => _scanTile(scan)),
      ],
    );
  }

  Widget _scanTile(Map<String, String> scan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: const Icon(Icons.person, color: Colors.indigo),
        ),
        title: Text(
          scan["name"] ?? "",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${scan["id"] ?? ""}\n• ${scan["violation"] ?? ""}\n${scan["department"] ?? ""}",
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        trailing: _offenseBadge(scan["offense"] ?? "", scan["time"] ?? ""),
      ),
    );
  }

  Widget _offenseBadge(String offense, String? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: offense == "1st"
                ? Colors.yellow.shade700
                : offense == "2nd"
                ? Colors.orange
                : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$offense Offense",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (time != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(time, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 550,
                width: MediaQuery.of(context).size.width * 0.9,
                child: _ScanHistoryModal(scanData: scanData),
              ),
            ),
          );
        },
        child: const Text(
          "View All Scan History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// ------------------- Scan History Modal -------------------
class _ScanHistoryModal extends StatefulWidget {
  final List<Map<String, String>> scanData;
  const _ScanHistoryModal({required this.scanData});

  @override
  State<_ScanHistoryModal> createState() => _ScanHistoryModalState();
}

class _ScanHistoryModalState extends State<_ScanHistoryModal> {
  String searchQuery = "";
  List<String> selectedStatuses = [];
  List<String> selectedViolations = [];
  List<String> selectedDepartments = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final filteredData = widget.scanData.where((scan) {
      final matchesSearch =
          scan["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          scan["id"]!.contains(searchQuery);
      final matchesStatus =
          selectedStatuses.isEmpty ||
          selectedStatuses.contains(scan["offense"]);
      final matchesViolation =
          selectedViolations.isEmpty ||
          selectedViolations.contains(scan["violation"]);
      final matchesDepartment =
          selectedDepartments.isEmpty ||
          selectedDepartments.contains(scan["department"]);

      final scanTime = DateTime.tryParse(scan["time"] ?? "");
      final matchesDate =
          (startDate == null ||
              (scanTime != null &&
                  scanTime.isAfter(
                    startDate!.subtract(const Duration(days: 1)),
                  ))) &&
          (endDate == null ||
              (scanTime != null &&
                  scanTime.isBefore(endDate!.add(const Duration(days: 1)))));

      return matchesSearch &&
          matchesStatus &&
          matchesViolation &&
          matchesDepartment &&
          matchesDate;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Scan History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by name or student ID",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.indigo),
                onPressed: () => _showFilterOptions(context),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),
        if (selectedStatuses.isNotEmpty ||
            selectedViolations.isNotEmpty ||
            selectedDepartments.isNotEmpty ||
            startDate != null ||
            endDate != null)
          Wrap(
            spacing: 6,
            children: [
              ...selectedStatuses.map((s) => _buildChip(s, Colors.orange)),
              ...selectedViolations.map((v) => _buildChip(v, Colors.blue)),
              ...selectedDepartments.map((d) => _buildChip(d, Colors.green)),
              if (startDate != null)
                _buildChip(
                  "From: ${startDate!.toLocal().toIso8601String().split('T')[0]}",
                  Colors.purple,
                ),
              if (endDate != null)
                _buildChip(
                  "To: ${endDate!.toLocal().toIso8601String().split('T')[0]}",
                  Colors.purple,
                ),
            ],
          ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredData.isEmpty
              ? const Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: const Icon(Icons.person, color: Colors.indigo),
                      ),
                      title: Text(
                        filteredData[index]["name"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${filteredData[index]["id"]} • ${filteredData[index]["violation"]}\n${filteredData[index]["department"]}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: filteredData[index]["offense"] == "1st"
                                  ? Colors.yellow.shade700
                                  : filteredData[index]["offense"] == "2nd"
                                  ? Colors.orange
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${filteredData[index]["offense"]} Offense",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filteredData[index]["time"] ?? "",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Options",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Wrap(
                      spacing: 8,
                      children: ["1st", "2nd", "3rd"].map((status) {
                        final isSelected = selectedStatuses.contains(status);
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: Colors.orange.shade300,
                          onSelected: (val) {
                            setModalState(() {
                              val
                                  ? selectedStatuses.add(status)
                                  : selectedStatuses.remove(status);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Violation",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            "Academic Dishonesty",
                            "Improper Uniform",
                            "Late Attendance",
                            "Serious Misconduct",
                            "Improper Conduct",
                          ].map((violation) {
                            final isSelected = selectedViolations.contains(
                              violation,
                            );
                            return ChoiceChip(
                              label: Text(violation),
                              selected: isSelected,
                              selectedColor: Colors.blue.shade300,
                              onSelected: (val) {
                                setModalState(() {
                                  val
                                      ? selectedViolations.add(violation)
                                      : selectedViolations.remove(violation);
                                });
                              },
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Department",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            "College of Arts & Sciences",
                            "College of Computer Studies",
                            "College of Education",
                            "College of Criminology",
                            "College of Business Administration",
                          ].map((dept) {
                            final isSelected = selectedDepartments.contains(
                              dept,
                            );
                            return ChoiceChip(
                              label: Text(dept),
                              selected: isSelected,
                              selectedColor: Colors.green.shade300,
                              onSelected: (val) {
                                setModalState(() {
                                  val
                                      ? selectedDepartments.add(dept)
                                      : selectedDepartments.remove(dept);
                                });
                              },
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Date Range",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null)
                                setModalState(() => startDate = picked);
                            },
                            child: Text(
                              startDate == null
                                  ? "Start Date"
                                  : startDate!
                                        .toLocal()
                                        .toIso8601String()
                                        .split('T')[0],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null)
                                setModalState(() => endDate = picked);
                            },
                            child: Text(
                              endDate == null
                                  ? "End Date"
                                  : endDate!.toLocal().toIso8601String().split(
                                      'T',
                                    )[0],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedStatuses.clear();
                              selectedViolations.clear();
                              selectedDepartments.clear();
                              startDate = null;
                              endDate = null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Clear All"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
      onDeleted: () {
        setState(() {
          selectedStatuses.remove(label);
          selectedViolations.remove(label);
          selectedDepartments.remove(label);
          if (label.startsWith("From:")) startDate = null;
          if (label.startsWith("To:")) endDate = null;
        });
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.logout, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                "Confirm Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to log out?\nAny unsaved scan data will be lost.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Logout"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Text(
                  "JM",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Jose Martinez",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoField(
                label: "Your Email",
                value: "jose.martinez@cityofmalabon...",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                label: "Password",
                value: "********",
                icon: Icons.visibility_off,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                label: "Department",
                value: "Safety and Security Office",
                icon: Icons.business_outlined,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}
