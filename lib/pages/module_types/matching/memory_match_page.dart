import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hearbat/models/memory_game.dart';
import 'package:hearbat/widgets/game_button.dart';
import 'package:hearbat/widgets/game_timer.dart';
import 'package:hearbat/widgets/memory_card.dart';

class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({
    super.key,
  });
  @override
  State<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends State<MemoryMatchPage> {
  Timer? timer;
  MemoryGame? game;

  @override
  void initState() {
    super.initState();
    game = MemoryGame(4);
    startTimer();
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        game!.time = game!.time + 1;
      });

      if (game!.isGameOver) {
        timer!.cancel();
      }
    });
  }

  void _resetGame() {
    game!.resetGame();
    setState(() {
      timer!.cancel();
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: GameTimer(
                time: game!.time,
              ),
            ),
            Expanded(
              flex: 3,
              child: GridView.count(
                crossAxisCount: game!.gridSize,
                children: List.generate(game!.cards.length, (index) {
                  return MemoryCard(
                    index: index,
                    cardItem: game!.cards[index],
                    onCardPressed: game!.onCardPressed,
                  );
                }),
              ),
            ),
            if (game!.isGameOver)
              Expanded(
                flex: 1,
                child: GameButton(
                  onPressed: () => _resetGame(),
                  title: 'TRY AGAIN',
                ),
              )
            else
              const Expanded(
                flex: 1,
                child: SizedBox(),
              )
          ],
        ),
      ),
    );
  }
}