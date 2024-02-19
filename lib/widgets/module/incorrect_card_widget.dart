import 'package:flutter/material.dart';
import 'package:hearbat/data/answer_pair.dart';
import '../../utils/google_tts_util.dart';
import '../../utils/audio_util.dart';

class IncorrectCardWidget extends StatefulWidget {
  final Answer incorrectWord;
  final Answer correctWord;
  final String voiceType;
  final bool isWord;

  IncorrectCardWidget({
    Key? key,
    required this.incorrectWord,
    required this.correctWord,
    required this.voiceType,
    required this.isWord,
  }) : super(key: key);

  @override
  IncorrectCardWidgetState createState() => IncorrectCardWidgetState();
}

class IncorrectCardWidgetState extends State<IncorrectCardWidget> {
  GoogleTTSUtil googleTTSUtil = GoogleTTSUtil();

  @override
  void initState() {
    super.initState();
  }

  void playAnswer(Answer answer) {
    if (widget.isWord) {
      googleTTSUtil.speak(answer.answer, widget.voiceType);
    }
    else {
      AudioUtil.playSound(answer.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Incorrect word button
          SizedBox(
            width: 160,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => playAnswer(widget.incorrectWord),
              icon: Icon(
                Icons.volume_up,
                color: const Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.incorrectWord.answer,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 22,
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 154, 107, 187),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
                shadowColor: Colors.grey[900],
              ),
            ),
          ),
          // Correct word button
          SizedBox(
            width: 160,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => playAnswer(widget.correctWord),
              icon: Icon(
                Icons.volume_up,
                color: const Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.correctWord.answer,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 154, 107, 187),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
                shadowColor: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
