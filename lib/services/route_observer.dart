import 'package:flutter/widgets.dart';

/// R26 S1v2-T2: shared RouteObserver so any screen can subscribe to
/// route lifecycle events (didPush / didPopNext / didPush / etc.)
/// without main.dart having to hand the instance around.
///
/// Currently used by the tent screen to re-read in-progress event
/// persistence the moment the tent becomes the active route again
/// (e.g., user backs out of an event scene).
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
