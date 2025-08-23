import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TournamentService {
  final String backendUrl = 'https://fyp-25-s2-08.onrender.com';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<List<dynamic>> getAllTournaments() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    print('TournamentService: JWT = $jwt');
    if (jwt == null) {
      print('TournamentService: No JWT found in secure storage!');
      throw Exception('JWT not found in secure storage');
    }
    final url = '$backendUrl/tournaments/all';
    print('TournamentService: Fetching tournaments from $url');
    final res = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'session=$jwt'},
    );
    print('TournamentService: Response status: ${res.statusCode}');
    print('TournamentService: Response body: ${res.body}');
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      print('TournamentService: Decoded tournaments: $decoded');
      return decoded;
    } else {
      print('TournamentService: Failed to load tournaments! Status: ${res.statusCode}, Body: ${res.body}');
      throw Exception('Failed to load tournaments');
    }
  }

  Future<List<dynamic>> getTournamentNamesAndEndDates() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    print('TournamentService: JWT = $jwt');
    if (jwt == null) {
      print('TournamentService: No JWT found in secure storage!');
      throw Exception('JWT not found in secure storage');
    }
    final url = '$backendUrl/tournaments/name-enddate';
    print('TournamentService: Fetching from $url');
    final res = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'session=$jwt'},
    );
    print('TournamentService: Response status: ${res.statusCode}');
    print('TournamentService: Response body: ${res.body}');
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      print('TournamentService: Decoded name-enddate: $decoded');
      return decoded;
    } else {
      print('TournamentService: Failed to load name/enddate! Status: ${res.statusCode}, Body: ${res.body}');
      throw Exception('Failed to load tournament name/enddate');
    }
  }

  // This method gets tournaments **with participant counts** from the backend
  Future<List<dynamic>> getTournamentsWithParticipants() async {
    final res = await http.get(
      Uri.parse('$backendUrl/tournaments/with-participants'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load tournaments with participants');
    }
  }

  Future<String> joinTournament(int tournamentId) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.post(
      Uri.parse('$backendUrl/tournaments/$tournamentId/join'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: '{}',
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded['status'];
    } else {
      throw Exception('Failed to join tournament');
    }
  }

  Future<List<dynamic>> getLeaderboard(int tournamentId) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$backendUrl/tournaments/$tournamentId/participants'),
      headers: {'Cookie': 'session=$jwt'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }
}