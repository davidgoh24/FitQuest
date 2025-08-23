import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

class _AuthedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

class GoogleCalendarService {
  GoogleCalendarService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
      GoogleSignIn(
        scopes: const [
          'email',
          'profile',
          'https://www.googleapis.com/auth/calendar',
        ],
      );

  final GoogleSignIn _googleSignIn;

  static const String _fitQuestTagKey = 'fitquest';
  static const String _fitQuestTagValue = '1';

  Future<Map<String, String>> _getAuthHeaders() async {
    GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    account ??= await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in was cancelled.');

    final granted = await _googleSignIn.requestScopes(
      ['https://www.googleapis.com/auth/calendar'],
    );
    if (granted != true) throw Exception('Calendar permission was not granted.');
    return account.authHeaders;
  }

  Future<void> signOutCalendar() async {
    await _googleSignIn.signOut();
  }



  /// Delete all events created by FitQuest (identified by extendedProperties).
  Future<int> unsyncFitQuestEvents({
    String calendarId = 'primary',
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    final headers = await _getAuthHeaders();
    final api = gcal.CalendarApi(_AuthedClient(headers));

    String? pageToken;
    int deleted = 0;

    do {
      final resp = await api.events.list(
        calendarId,
        privateExtendedProperty: ['$_fitQuestTagKey=$_fitQuestTagValue'], // <-- fix
        singleEvents: true,
        maxResults: 2500,
        pageToken: pageToken,
        timeMin: timeMin,
        timeMax: timeMax,
      );

      final items = resp.items ?? const <gcal.Event>[];
      for (final ev in items) {
        final id = ev.id;
        if (id != null) {
          await api.events.delete(calendarId, id);
          deleted++;
        }
      }
      pageToken = resp.nextPageToken;
    } while (pageToken != null && pageToken.isNotEmpty);

    return deleted;
  }

  Future<gcal.Event> addEvent({
    required String summary,
    required DateTime start,
    int durationMinutes = 45,
    String timeZone = 'Asia/Singapore',
    String? description,
    List<String>? attendeesEmails,
    String calendarId = 'primary',
    Map<String, String>? extraPrivateProps, // <--- NEW (optional)
  }) async {
    final headers = await _getAuthHeaders();
    final api = gcal.CalendarApi(_AuthedClient(headers));
    final end = start.add(Duration(minutes: durationMinutes));

    final event = gcal.Event(
      summary: summary,
      description: description,
      start: gcal.EventDateTime(dateTime: start, timeZone: timeZone),
      end: gcal.EventDateTime(dateTime: end, timeZone: timeZone),
      attendees: attendeesEmails?.map((e) => gcal.EventAttendee(email: e)).toList(),
      reminders: gcal.EventReminders(
        useDefault: false,
        overrides: [gcal.EventReminder(method: 'popup', minutes: 10)],
      ),
      // Tag it so we can find/delete later
      extendedProperties: gcal.EventExtendedProperties(private: {
        _fitQuestTagKey: _fitQuestTagValue,
        if (extraPrivateProps != null) ...extraPrivateProps,
      }),
    );

    return await api.events.insert(event, calendarId);
  }

  Future<List<gcal.Event>> addWholePlan({
    required List<dynamic> planDays,
    int defaultStartHour = 7,
    int defaultStartMinute = 0,
    int durationMinutesPerDay = 45,
    String timeZone = 'Asia/Singapore',
    String calendarId = 'primary',
  }) async {
    final headers = await _getAuthHeaders();
    final api = gcal.CalendarApi(_AuthedClient(headers));

    final created = <gcal.Event>[];

    for (int i = 0; i < planDays.length; i++) {
      final day = planDays[i];

      final date = day['calendar_date'];
      final isRest = (day['rest'] == true);
      if (date == null || date is! DateTime || isRest) continue;

      final idx = i + 1;
      final summary = _buildEventTitle(day, defaultTitle: 'Workout Day $idx');
      final description = _buildDescription(day);

      final start = DateTime(
        date.year,
        date.month,
        date.day,
        defaultStartHour,
        defaultStartMinute,
      );

      final event = gcal.Event(
        summary: summary,
        description: description,
        start: gcal.EventDateTime(dateTime: start, timeZone: timeZone),
        end: gcal.EventDateTime(
          dateTime: start.add(Duration(minutes: durationMinutesPerDay)),
          timeZone: timeZone,
        ),
        reminders: gcal.EventReminders(
          useDefault: false,
          overrides: [gcal.EventReminder(method: 'popup', minutes: 10)],
        ),
        extendedProperties: gcal.EventExtendedProperties(private: {
          _fitQuestTagKey: _fitQuestTagValue,
          'dayIndex': '$idx',
        }),
      );

      final inserted = await api.events.insert(event, calendarId);
      created.add(inserted);
    }

    return created;
  }

  Future<void> connectCalendar() async {
    await _getAuthHeaders(); // triggers sign-in + scope grant if needed
  }

  Future<int> disconnectCalendar({
    bool alsoUnsync = true,
    String calendarId = 'primary',
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    int removed = 0;

    GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
    } catch (_) {
      // ignore; we'll still try to signOut if needed
    }

    if (alsoUnsync) {
      try {
        removed = await unsyncFitQuestEvents(
          calendarId: calendarId,
          timeMin: timeMin,
          timeMax: timeMax,
        );
      } catch (_) {
      }
    }

    try {
      await _googleSignIn.disconnect();
      return removed;
    } on PlatformException catch (_) {
      try {
        account ??= await _googleSignIn.signInSilently();
        if (account != null) {
          final auth = await account.authentication;
          final token = auth.accessToken;
          if (token != null) {
            // Google OAuth revoke endpoint
            final uri = Uri.parse('https://oauth2.googleapis.com/revoke?token=$token');
            // POST with form content-type is accepted; GET also works.
            await http.post(
              uri,
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: 'token=$token',
            );
          }
        }
      } catch (_) {
      }
      await _googleSignIn.signOut();
      return removed;
    }
  }

  Future<List<gcal.Event>> addVisibleMonth({
    required List<dynamic> planDays,
    required DateTime visibleMonth,
    int defaultStartHour = 7,
    int defaultStartMinute = 0,
    int durationMinutesPerDay = 45,
    String timeZone = 'Asia/Singapore',
    String calendarId = 'primary',
  }) async {
    final month = DateTime(visibleMonth.year, visibleMonth.month);
    final nextMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);

    final subset = planDays.where((d) {
      final dt = d['calendar_date'];
      return (dt is DateTime) &&
          (d['rest'] != true) &&
          dt.isAfter(month.subtract(const Duration(seconds: 1))) &&
          dt.isBefore(nextMonth);
    }).toList();


    return addWholePlan(
      planDays: subset,
      defaultStartHour: defaultStartHour,
      defaultStartMinute: defaultStartMinute,
      durationMinutesPerDay: durationMinutesPerDay,
      timeZone: timeZone,
      calendarId: calendarId,
    );
  }

  String _buildEventTitle(Map<String, dynamic> day, {required String defaultTitle}) {
    final exs = (day['exercises'] as List?) ?? const [];
    if (exs.isNotEmpty) {
      final first = exs.first;
      final exName = (first['name'] ?? first['exerciseName'])?.toString();
      if (exName != null && exName.trim().isNotEmpty) {
        return 'Workout: $exName';
      }
    }
    return defaultTitle;
  }

  String _buildDescription(Map<String, dynamic> day) {
    final buffer = StringBuffer();
    final exs = (day['exercises'] as List?) ?? const [];
    if (exs.isNotEmpty) {
      buffer.writeln('Exercises:');
      for (final ex in exs) {
        final name = (ex['name'] ?? ex['exerciseName'])?.toString() ?? 'Exercise';
        final sets = (ex['sets'] ?? ex['exerciseSets'])?.toString() ?? '-';
        final reps = (ex['reps'] ?? ex['exerciseReps'])?.toString() ?? '-';
        buffer.writeln('• $name — ${sets}×${reps}');
      }
    }
    final notes = day['notes']?.toString();
    if (notes != null && notes.trim().isNotEmpty) {
      if (buffer.toString().isNotEmpty) buffer.writeln();
      buffer.writeln('Notes: $notes');
    }
    return buffer.toString().trim();
  }
}
