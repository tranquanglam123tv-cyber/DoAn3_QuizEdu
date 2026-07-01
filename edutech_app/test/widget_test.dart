import 'package:edutech_app/features/admin/provider/admin_provider.dart';
import 'package:edutech_app/features/auth/provider/auth_provider.dart';
import 'package:edutech_app/features/document/provider/document_provider.dart';
import 'package:edutech_app/features/exam/provider/exam_provider.dart';
import 'package:edutech_app/features/profile/provider/profile_provider.dart';
import 'package:edutech_app/features/quiz/provider/quiz_provider.dart';
import 'package:edutech_app/features/subject/provider/subject_provider.dart';
import 'package:edutech_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('app renders initial shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SubjectProvider()),
          ChangeNotifierProvider(create: (_) => DocumentProvider()),
          ChangeNotifierProvider(create: (_) => QuizProvider()),
          ChangeNotifierProvider(create: (_) => ExamProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('EduTech AI'), findsOneWidget);
  });
}
