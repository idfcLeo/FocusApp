import 'package:flutter_test/flutter_test.dart';
import 'package:college_student_kit/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const CollegeStudentKitApp());
    expect(find.byType(CollegeStudentKitApp), findsOneWidget);
  });
}
