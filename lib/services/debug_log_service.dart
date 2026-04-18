import 'dart:collection';

/// In-memory ring-buffer for diagnostic events shown to Khaled during
/// testing via the persistent debug overlay (see B27). Holds the most
/// recent [_maxEntries] entries; older entries are dropped.
///
/// Usage:
///   DebugLogService.log('video', 'Init timeout — skipping');
///   DebugLogService.log('hotspot', 'Health check healed HS2');
///
/// The overlay (B27) reads from [entries] and can export via [exportText].
class DebugLogService {
  static const int _maxEntries = 200;
  static final Queue<DebugLogEntry> _entries = Queue<DebugLogEntry>();
  static final List<void Function()> _listeners = [];

  static List<DebugLogEntry> get entries => List.unmodifiable(_entries);

  static void log(String category, String message) {
    final entry = DebugLogEntry(
      category: category,
      message: message,
      time: DateTime.now(),
    );
    _entries.addLast(entry);
    while (_entries.length > _maxEntries) {
      _entries.removeFirst();
    }
    for (final l in _listeners) {
      l();
    }
  }

  static void addListener(void Function() l) => _listeners.add(l);
  static void removeListener(void Function() l) => _listeners.remove(l);

  static void clear() {
    _entries.clear();
    for (final l in _listeners) {
      l();
    }
  }

  /// Export as plain text — user taps "copy" in the overlay and pastes.
  static String exportText() {
    final buf = StringBuffer();
    buf.writeln('RAWI DEBUG LOG — ${DateTime.now().toIso8601String()}');
    buf.writeln('entries: ${_entries.length}');
    buf.writeln('---');
    for (final e in _entries) {
      buf.writeln(
          '${e.time.toIso8601String()}  [${e.category}]  ${e.message}');
    }
    return buf.toString();
  }
}

class DebugLogEntry {
  final String category;
  final String message;
  final DateTime time;

  const DebugLogEntry({
    required this.category,
    required this.message,
    required this.time,
  });
}
