import 'package:flutter/material.dart';

void main() => runApp(SchoolGuardApp());

class SchoolGuardApp extends StatelessWidget {
  const SchoolGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SchoolGuardHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SchoolGuardHome extends StatelessWidget {
  final List<Map<String, String>> scanData = [
    {
      "name": "Annie Batumbakal",
      "id": "202205249",
      "offense": "1st",
      "time": "2 mins",
    },
    {
      "name": "Juan Dela Cruz",
      "id": "202205232",
      "offense": "2nd",
      "time": "5 mins",
    },
    {
      "name": "James Reid",
      "id": "202205211",
      "offense": "3rd",
      "time": "10 mins",
    },
    {
      "name": "Sponge Cola",
      "id": "202209211",
      "offense": "1st",
      "time": "15 mins",
    },
  ];

  SchoolGuardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              _buildRecentScans(scanData),
              const SizedBox(height: 20),
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
        color: Colors.indigo.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Safety and Security Office\nCMU - DRMS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("47", "Students scanned"),
              _statBox("12", "Violations today"),
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
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildScannerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade300, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.camera_alt, size: 48, color: Colors.blue),
          const SizedBox(height: 10),
          const Text(
            "Ready to scan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text("Position the student ID card in front of the camera"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Start Scan"),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...data.take(2).map((scan) => _scanTile(scan)),
      ],
    );
  }

  Widget _scanTile(Map<String, String> scan) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(scan["name"] ?? ""),
        subtitle: Text(scan["id"] ?? ""),
        trailing: _offenseBadge(scan["offense"] ?? "", scan["time"]),
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
                ? Colors.yellow
                : offense == "2nd"
                ? Colors.orange
                : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("$offense Offense", style: const TextStyle(fontSize: 12)),
        ),
        if (time != null) Text(time, style: const TextStyle(fontSize: 12)),
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
                height: 500,
                width: MediaQuery.of(context).size.width * 0.9,
                child: _ScanHistoryModal(scanData: scanData),
              ),
            ),
          );
        },
        child: const Text("View All Scan History"),
      ),
    );
  }
}

class _ScanHistoryModal extends StatelessWidget {
  final List<Map<String, String>> scanData;

  const _ScanHistoryModal({required this.scanData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Scan History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by name or student ID",
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: scanData.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(scanData[index]["name"] ?? ""),
                subtitle: Text(scanData[index]["id"] ?? ""),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scanData[index]["offense"] == "1st"
                            ? Colors.yellow
                            : scanData[index]["offense"] == "2nd"
                            ? Colors.orange
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${scanData[index]["offense"]} Offense",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scanData[index]["time"] ?? "",
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
}
