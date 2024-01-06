import 'package:flutter/material.dart';
import 'package:hearbat/data/answer_pair.dart';
class WordButton extends StatelessWidget {
  final Answer word;
  final Answer? selectedWord;
  final ValueChanged<Answer> onSelected;

  const WordButton({
    Key? key,
    required this.word,
    required this.selectedWord,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onSelected(word),
      style: ElevatedButton.styleFrom(
        backgroundColor : selectedWord == word
          ? Colors.grey
          : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        word.answer,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}