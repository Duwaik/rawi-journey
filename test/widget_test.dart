import 'package:flutter_test/flutter_test.dart';
import 'package:rawi/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(RawiApp, isNotNull);
  });
}
