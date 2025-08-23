import 'package:flutter/material.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final List<Map<String, dynamic>> competitions = [
    {
      "opponent": "Alex",
      "status": "Challenged you",
      "details": [
        {"label": "Push Ups", "type": "reps", "value": 20},
        {"label": "Plank", "type": "duration", "value": 40},
      ],
      "accepted": false,
      "completed": false,
    },
    {
      "opponent": "Jordan",
      "status": "You’re winning",
      "details": [
        {"label": "Sit Ups", "type": "reps", "value": 15},
      ],
      "accepted": true,
      "completed": false,
    },
    {
      "opponent": "Sam",
      "status": "Tie",
      "details": [
        {"label": "Wall Sit", "type": "duration", "value": 45},
      ],
      "accepted": true,
      "completed": true,
    },
  ];

  void handleChallenge(int index) {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF071655),
              Color(0xFF263874),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: Container(
              width: constraints.maxWidth > 500 ? 420 : double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(Icons.arrow_back, color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Competitions",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Your Current Challenges",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  competitions.isNotEmpty
                      ? Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: competitions.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, i) {
                        final item = competitions[i];
                        return _NiceCompetitionCard(
                          opponent: item["opponent"],
                          status: item["status"],
                          onAction: () => handleChallenge(i),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 13),
                    ),
                  )
                      : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: Text(
                        "No ongoing challenge yet.",
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 27),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE066), Color(0xFFFFC300)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.13),
                              blurRadius: 18,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add, color: Colors.black, size: 22),
                            SizedBox(width: 14),
                            Text(
                              "Start New Challenge",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NiceCompetitionCard extends StatelessWidget {
  final String opponent;
  final String status;
  final VoidCallback onAction;

  const _NiceCompetitionCard({
    required this.opponent,
    required this.status,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onAction,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFC300).withOpacity(0.75),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFE066),
              radius: 22,
              child: Text(
                opponent.characters.first,
                style: const TextStyle(
                    color: Color(0xFF071655),
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponent,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16.5,
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFFFE066), size: 28),
          ],
        ),
      ),
    );
  }
}