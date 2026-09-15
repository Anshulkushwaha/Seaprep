import 'package:flutter_test/flutter_test.dart';
import 'package:seaprep_app/main.dart';

void main() {
  testWidgets('SeaPrepApp loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SeaPrepApp());
    expect(find.textContaining('SeaPrep'), findsWidgets);
  });
}
