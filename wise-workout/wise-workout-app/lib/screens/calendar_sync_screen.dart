import 'package:flutter/material.dart';
import '../../services/google_calendar_service.dart';

class CalendarSyncArgs {
  final List<dynamic>? planDays;
  final DateTime? visibleMonth;
  const CalendarSyncArgs({this.planDays, this.visibleMonth});
}

class CalendarSyncScreen extends StatefulWidget {
  static const routeName = '/calendar-sync';
  final CalendarSyncArgs? args;
  const CalendarSyncScreen({super.key, this.args});

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  final _gCal = GoogleCalendarService();
  bool _busy = false;

  bool get _canSyncMonth =>
      (widget.args?.planDays != null && widget.args!.planDays!.isNotEmpty);

  Future<void> _syncThisMonth() async {
    if (!_canSyncMonth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No plan days provided to sync.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final month = widget.args?.visibleMonth ?? DateTime.now();
      final created = await _gCal.addVisibleMonth(
        planDays: widget.args!.planDays!,
        visibleMonth: month,
        calendarId: 'primary',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced ${created.length} event(s) to Calendar.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    try {
      await _gCal.connectCalendar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected to Google Calendar.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect({required bool removeEvents}) async {
    setState(() => _busy = true);
    try {
      final removed = await _gCal.disconnectCalendar(
        alsoUnsync: removeEvents,
        calendarId: 'primary',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            removeEvents
                ? 'Disconnected. Removed $removed event(s).'
                : 'Disconnected. Existing events kept.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disconnect failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Sync'),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Inside the ListView children in build()
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: cs.shadow.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                      backgroundColor: cs.primary,
                      child: Icon(Icons.calendar_month, color: cs.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Text('Google Calendar', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _connect,
                      icon: const Icon(Icons.link),
                      label: const Text('Connect to Google Calendar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: cs.shadow.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Disconnect', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Revoke access and optionally remove FitQuest events.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : () => _disconnect(removeEvents: false),
                          icon: const Icon(Icons.link_off),
                          label: const Text('Disconnect (Keep Events)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _busy ? null : () => _disconnect(removeEvents: true),
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Disconnect & Remove Events'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: If you open this from your calendar plan page, pass the same planDays and month as arguments to enable “Sync This Month”.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
