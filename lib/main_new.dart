import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'logic/auth_controller_simple.dart';
import 'logic/quiz_controller.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/quiz_detail_screen.dart';
import 'ui/screens/play_quiz_screen.dart';
import 'ui/screens/result_screen.dart';

void main() {
  runApp(const QuizKingApp());
}

class QuizKingApp extends StatelessWidget {
  const QuizKingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => QuizController()),
      ],
      child: MaterialApp(
        title: 'Prepking AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/quiz-detail': (context) => const QuizDetailScreen(),
          '/play': (context) => const PlayQuizScreen(),
          '/result': (context) => const ResultScreen(),
        },
      ),
    );
  }
}
