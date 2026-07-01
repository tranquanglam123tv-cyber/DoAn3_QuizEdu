import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/screen/login_screen.dart';
import 'features/auth/screen/register_screen.dart';
import 'features/subject/provider/subject_provider.dart';
import 'features/subject/screen/subject_screen.dart';
import 'features/document/provider/document_provider.dart';
import 'features/document/screen/document_screen.dart';
import 'features/document/model/document_model.dart';
import 'features/ai/screen/ai_screen.dart';
import 'features/ai/screen/ai_hub_screen.dart';
import 'features/quiz/provider/quiz_provider.dart';
import 'features/quiz/screen/quiz_config_screen.dart';
import 'features/quiz/screen/quiz_preview_screen.dart';
import 'features/quiz/model/quiz_model.dart';
import 'features/exam/provider/exam_provider.dart';
import 'features/exam/screen/exam_screen.dart';
import 'features/exam/screen/result_screen.dart';
import 'features/dashboard/screen/dashboard_screen.dart';
import 'features/profile/screen/profile_screen.dart';
import 'features/profile/provider/profile_provider.dart';
import 'features/admin/screen/admin_screen.dart';
import 'features/admin/provider/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
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
}

GoRouter _buildRouter(AuthProvider auth) => GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isAuth = auth.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/home';
    return null;
  },
  refreshListenable: auth,
  routes: [
    GoRoute(path: '/login', builder: (_, s) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, s) => const RegisterScreen()),

    // Shell route — bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        // Branch 0 — Home (Dashboard)
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, s) => const DashboardScreen()),
          ],
        ),
        // Branch 1 — Subjects
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/subjects',
              builder: (_, s) => const SubjectScreen(),
              routes: [
                GoRoute(
                  path: ':subjectId/documents',
                  builder: (context, state) {
                    final subjectId = int.parse(state.pathParameters['subjectId']!);
                    final subjectName = state.extra as String? ?? 'Tài liệu';
                    return DocumentScreen(subjectId: subjectId, subjectName: subjectName);
                  },
                  routes: [
                    GoRoute(
                      path: ':documentId/ai',
                      builder: (context, state) {
                        if (state.extra is! DocumentModel) {
                          return const Scaffold(
                            body: Center(child: Text('Không tìm thấy tài liệu')),
                          );
                        }
                        final doc = state.extra as DocumentModel;
                        return AIScreen(documentId: doc.id, documentName: doc.fileName);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/documents/:documentId/quiz',
              builder: (context, state) {
                final documentId = int.parse(state.pathParameters['documentId']!);
                final documentName = state.extra as String? ?? 'Tài liệu';
                return QuizConfigScreen(documentId: documentId, documentName: documentName);
              },
            ),
            GoRoute(
              path: '/quiz/:quizId/preview',
              builder: (context, state) {
                if (state.extra is! QuizModel) {
                  return const Scaffold(
                    body: Center(child: Text('Không tìm thấy đề thi')),
                  );
                }
                return QuizPreviewScreen(quiz: state.extra as QuizModel);
              },
            ),
            GoRoute(
              path: '/quiz/:quizId/take',
              builder: (context, state) {
                if (state.extra is! QuizModel) {
                  return const Scaffold(
                    body: Center(child: Text('Không tìm thấy đề thi')),
                  );
                }
                final quiz = state.extra as QuizModel;
                return ExamScreen(quiz: quiz);
              },
            ),
            GoRoute(
              path: '/exam/:examId/result',
              builder: (_, s) => const ResultScreen(),
            ),
          ],
        ),
        // Branch 2 — AI Hub
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/ai-hub', builder: (_, s) => const AiHubScreen()),
          ],
        ),
        // Branch 3 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, s) => const ProfileScreen()),
          ],
        ),
        // Branch 4 — Admin (hidden, accessible via /admin route)
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/admin', builder: (_, s) => const AdminScreen()),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _SplashScreen(),
      );
    }

    _router ??= _buildRouter(auth);

    return MaterialApp.router(
      title: 'EduTech AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router!,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text('EduTech AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}
