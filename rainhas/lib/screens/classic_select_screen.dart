import 'package:flutter/material.dart';

import '../game/solver.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import '../widgets/game_ui.dart';
import 'queens_game_screen.dart';

const classicSizes = [4, 5, 6, 7, 8, 9, 10, 11, 12];

class ClassicSelectScreen extends StatefulWidget {
  const ClassicSelectScreen({super.key});

  @override
  State<ClassicSelectScreen> createState() => _ClassicSelectScreenState();
}

class _ClassicSelectScreenState extends State<ClassicSelectScreen> {
  Future<void> _play(int n) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QueensGameScreen.classic(n: n)),
    );
    setState(() {}); // atualiza o progresso
  }

  @override
  Widget build(BuildContext context) {
    final progress = Progress.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Clássico')),
      bottomNavigationBar: const BannerAdBox(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final n in classicSizes)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                leading: CircleAvatar(child: Text('$n')),
                title: Text('Tabuleiro $n×$n'),
                subtitle: Text(_subtitle(progress, n)),
                trailing: const Icon(Icons.play_arrow_rounded, size: 32),
                onTap: () => _play(n),
              ),
            ),
        ],
      ),
    );
  }

  String _subtitle(Progress progress, int n) {
    final found = progress.foundSolutions(n).length;
    final total = allSolutions(n).length;
    final best = progress.bestTime(n);
    final record = best == null ? '' : ' · recorde ${formatTime(best)}';
    return 'Soluções: $found de $total$record';
  }
}
