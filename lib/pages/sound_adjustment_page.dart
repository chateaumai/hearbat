import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../widgets/top_bar_widget.dart';
import 'navigation_bar.dart';

class SoundAdjustmentPage extends StatefulWidget {
  @override
  SoundAdjustmentPageState createState() => SoundAdjustmentPageState();
}

class SoundAdjustmentPageState extends State<SoundAdjustmentPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final String audioPath = 'audio/background/jazz.mp3';

  @override
  void initState() {
    super.initState();
    playSound();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  void playSound() async {
    await audioPlayer.play(AssetSource(audioPath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please adjust your \nsound settings',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyNavBar()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: Size(200, 60), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  child: Text(
                    'Ready',
                    style: TextStyle(
                      fontSize: 24
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, 100),
              child: Image.asset(
                'assets/visuals/HB_Default.png',
                width: MediaQuery.of(context).size.width * 0.75,
                fit: BoxFit.cover, 
              ),
            )
          ),
        ],
      ),
    );
  }
}
