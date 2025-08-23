import 'package:flutter/material.dart';

class WorkoutSummaryPage extends StatefulWidget {
  const WorkoutSummaryPage({super.key});

  @override
  State<WorkoutSummaryPage> createState() => _WorkoutSummaryPageState();
}

class _WorkoutSummaryPageState extends State<WorkoutSummaryPage> {
  String selectedTab = "Weekly";

  final tabs = ["Daily", "Weekly", "Monthly"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text("Summary", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = tab == selectedTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedTab = tab);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.chevron_left),
                SizedBox(width: 4),
                Text("16 Jun - 22 Jun", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right),
              ],
            ),

            const SizedBox(height: 16),

            _buildSummaryCard(
              icon: Icons.directions_walk,
              title: "Steps",
              current: "4,300",
              avg: "9,121",
              barColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.local_fire_department,
              title: "Calories",
              current: "321",
              avg: "234",
              barColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String current,
    required String avg,
    required Color barColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: barColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(current, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Current"),
                ],
              ),
              Column(
                children: [
                  Text(avg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Avg"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            color: Colors.grey[100],
            alignment: Alignment.center,
            child: Text("Insert ${title.toLowerCase()} chart here", style: const TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}
