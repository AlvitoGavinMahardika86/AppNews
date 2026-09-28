import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/main.dart';

void main() {
  testWidgets('renders the NewsHub splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NewsHub'), findsOneWidget);
    expect(find.text('Stay Updated with Latest News'), findsOneWidget);
  });
}
