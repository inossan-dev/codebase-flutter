import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codebase/main.dart';

void main() {
  testWidgets('AppRoot renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AppRoot()),
    );
    // Le login screen devrait apparaître (non authentifié)
    await tester.pumpAndSettle();
    expect(find.text('Connexion'), findsOneWidget);
  });
}
