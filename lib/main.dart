import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/game_screen.dart';
import 'services/word_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final wordList = await WordList.load();

  runApp(KristleApp(wordList: wordList));
}

class KristleApp extends StatelessWidget {
  const KristleApp({
    super.key,
    required this.wordList,
    this.enableAnswerReveal = AppConfig.enableAnswerReveal,
  });

  final WordList wordList;
  final bool enableAnswerReveal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kristle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: GameScreen(
        wordList: wordList,
        enableAnswerReveal: enableAnswerReveal,
      ),
    );
  }
}
