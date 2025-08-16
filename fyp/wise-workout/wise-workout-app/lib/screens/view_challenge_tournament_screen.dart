import 'package:flutter/material.dart';
import '../widgets/view_challenge_widget.dart';
import '../widgets/view_tournament_widget.dart';
import '../services/tournament_service.dart';
import '../services/challenge_service.dart';

class ViewChallengeTournamentScreen extends StatefulWidget {
  final bool isPremium;
  const ViewChallengeTournamentScreen({super.key, required this.isPremium});

  @override
  State<ViewChallengeTournamentScreen> createState() => _ViewChallengeTournamentScreenState();
}

class _ViewChallengeTournamentScreenState extends State<ViewChallengeTournamentScreen> {
  late Future<List<dynamic>> tournamentsFuture;
  late Future<List<Map<String, dynamic>>> challengesFuture;
  final TournamentService _tournamentService = TournamentService();
  final ChallengeService _challengeService = ChallengeService();
  List<Map<String, dynamic>>? editableChallenges;

  @override
  void initState() {
    super.initState();
    challengesFuture = _challengeService.getAllChallenges();
    tournamentsFuture = _tournamentService.getAllTournaments();
  }

  void reloadTournaments() {
    setState(() {
      tournamentsFuture = _tournamentService.getAllTournaments();
    });
  }

  void editChallenge(int index, Map<String, dynamic> originalChallenge) async {
    String currentDurationValue = originalChallenge['duration']?.toString() ?? '';
    String currentDurationUnit = originalChallenge['duration_unit']?.toString() ?? 'days';
    if (currentDurationValue.contains(' ')) {
      final parts = currentDurationValue.split(' ');
      currentDurationValue = parts[0];
      if (parts.length > 1) currentDurationUnit = parts[1];
    }
    // Show edit dialog with value/unit separated
    final updated = await showEditChallengePopup(
      context,
      "${originalChallenge['value']} ${originalChallenge['unit']}", // Pass as "150 Push Ups"
      '$currentDurationValue $currentDurationUnit',
    );
    if (updated != null) {
      setState(() {
        if (editableChallenges != null && index < editableChallenges!.length) {
          final durParts = updated['duration']?.split(' ') ?? [];
          final durValue = durParts.isNotEmpty ? int.tryParse(durParts[0]) : null;
          final durUnit = durParts.length > 1 ? durParts[1] : 'days';

          // Parse the new value/unit from the edited string
          final targetParts = updated['target']?.split(' ') ?? [];
          final targetValue = targetParts.isNotEmpty ? int.tryParse(targetParts[0]) ?? 0 : 0;
          final targetUnit = targetParts.length > 1 ? targetParts.sublist(1).join(' ') : '';

          editableChallenges![index]['value'] = targetValue;
          editableChallenges![index]['unit'] = targetUnit;
          editableChallenges![index]['duration'] = durValue ?? editableChallenges![index]['duration'];
          editableChallenges![index]['duration_unit'] = durUnit;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.isPremium ? 2 : 1,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1741),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1741),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2B5C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                tabs: widget.isPremium
                    ? const [Tab(text: 'Challenge'), Tab(text: 'Tournament')]
                    : const [Tab(text: 'Tournament')],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                indicator: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: widget.isPremium
              ? [
                  buildChallengeTab(context),
                  buildTournamentTab(context),
                ]
              : [buildTournamentTab(context)],
        ),
      ),
    );
  }

  Widget buildChallengeTab(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: challengesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load challenges\n${snapshot.error}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }
        List<Map<String, dynamic>> challenges = snapshot.data ?? [];
        if (editableChallenges == null) {
          editableChallenges = challenges.map((e) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(e);
            map['duration_unit'] ??= 'days';
            return map;
          }).toList();
        }
        if (editableChallenges!.isEmpty) {
          return const Center(
            child: Text('No challenges found.', style: TextStyle(color: Colors.white)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: editableChallenges!.length,
          itemBuilder: (context, index) {
            final challenge = editableChallenges![index];
            final unit = challenge['duration_unit'] ?? 'days';
            return ChallengeCard(
              title: challenge['type'],
              target: "${challenge['value']} ${challenge['unit']}", // Always show as e.g. "150 Push Ups"
              duration: '${challenge['duration']} $unit',
              onInvite: () => showInviteFriendPopup(
                context,
                challenge['type'],
                "${challenge['value']} ${challenge['unit']}",
                '${challenge['duration']} $unit',
              ),
              onEdit: () => editChallenge(index, challenge),
            );
          },
        );
      },
    );
  }

  Widget buildTournamentTab(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: tournamentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load tournaments\n${snapshot.error}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }
        final tournaments = snapshot.data ?? [];
        if (tournaments.isEmpty) {
          return const Center(
            child: Text('No tournaments found.', style: TextStyle(color: Colors.white)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tournaments.length,
          itemBuilder: (context, index) {
            final t = tournaments[index];
            return TournamentCard(
              tournament: {
                'id': t['id'],
                'title': t['title'],
                'description': t['description'],
                'endDate': t['endDate'],
                'features': (t['features'] as List).map((e) => e.toString()).toList(),
              },
              onJoin: () => showTournamentJoinPopup(
                context,
                {
                  'id': t['id'],
                  'title': t['title'],
                  'description': t['description'],
                  'endDate': t['endDate'],
                  'features': (t['features'] as List).map((e) => e.toString()).toList(),
                },
                onJoin: () async {
                  String status = "";
                  try {
                    status = await _tournamentService.joinTournament(t['id']);
                  } catch (e) {
                    status = "";
                  }
                  if (!mounted) return;
                  if (status == "joined") {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Joined tournament!")));
                    reloadTournaments();
                  } else if (status == "already_joined") {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("You have already joined this tournament!")));
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Could not join tournament.")));
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
