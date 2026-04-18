import 'package:flutter/widgets.dart';

import '../services/debug_log_service.dart';

/// R25-S1-6: NavigatorObserver that feeds every route transition into the
/// debug log. Wire into MaterialApp.navigatorObservers so every push, pop,
/// and replace is captured with a timestamp + route name + args summary.
///
/// Logs go under the 'nav' category so Khaled can filter easily.
class DebugNavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    DebugLogService.log('nav',
        'push ${_routeLabel(route)}  (prev=${_routeLabel(previousRoute)})');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    DebugLogService.log('nav',
        'pop ${_routeLabel(route)}  (now=${_routeLabel(previousRoute)})');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    DebugLogService.log('nav',
        'replace ${_routeLabel(oldRoute)} → ${_routeLabel(newRoute)}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    DebugLogService.log('nav',
        'remove ${_routeLabel(route)}  (prev=${_routeLabel(previousRoute)})');
  }

  String _routeLabel(Route? route) {
    if (route == null) return '—';
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    // Anonymous routes (MaterialPageRoute without name) — show the builder
    // type, which resolves to the target screen's class name via toString.
    final rs = route.toString();
    // Keep it short: "MaterialPageRoute<dynamic>(...)" → "MaterialPageRoute"
    final paren = rs.indexOf('(');
    final short = paren > 0 ? rs.substring(0, paren) : rs;
    return short;
  }
}
