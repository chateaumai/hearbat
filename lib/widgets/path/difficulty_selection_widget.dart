import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hearbat/data/answer_pair.dart';
import 'package:hearbat/utils/google_tts_util.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../module/module_widget.dart';
import 'package:hearbat/utils/cache_words_util.dart';

class DifficultySelectionWidget extends StatefulWidget {
  final String moduleName;
  final List<AnswerGroup> answerGroups;

  DifficultySelectionWidget(
      {required this.moduleName, required this.answerGroups});

  @override
  DifficultySelectionWidgetState createState() =>
      DifficultySelectionWidgetState();
}

class DifficultySelectionWidgetState extends State<DifficultySelectionWidget> {
  String? _voicePreference;
  String _backgroundSound = 'None';
  String _audioVolume = 'Low';
  final GoogleTTSUtil _googleTTSUtil = GoogleTTSUtil();
  final CacheWordsUtil cacheUtil = CacheWordsUtil();
  bool isCaching = false;
  AudioPlayer audioPlayer = AudioPlayer();
  String? _voiceType;

  List<String> voiceTypes = [
    "en-US-Studio-O",
    // "en-US-Neural2-C",
    "en-GB-Neural2-C",
    "en-IN-Neural2-A",
    "en-AU-Neural2-C",
    "en-US-Studio-Q",
    // "en-US-Neural2-D",
    "en-GB-Neural2-B",
    "en-IN-Neural2-B",
    "en-AU-Neural2-B",
  ];

  Map<String, String> voiceTypeTitles = {
    "en-US-Studio-O": "US Female",
    //"en-US-Neural2-C": "US2 Female",
    "en-GB-Neural2-C": "UK Female",
    "en-IN-Neural2-A": "IN Female",
    "en-AU-Neural2-C": "AU Female",
    "en-US-Studio-Q": "US Male",
    // "en-US-Neural2-D": "US2 Male",
    "en-GB-Neural2-B": "UK Male",
    "en-IN-Neural2-B": "IN Male",
    "en-AU-Neural2-B": "AU Male",
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadVoiceType();
    _cacheVoiceTypes();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _voicePreference = prefs.getString('voicePreference') ?? "en-US-Studio-O";
      _backgroundSound = prefs.getString('backgroundSoundPreference') ?? 'None';
      _audioVolume = prefs.getString('audioVolumePreference') ?? 'Low';
    });
    _adjustVolume(_audioVolume);
  }

  void _loadVoiceType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceType = prefs.getString('voicePreference') ??
          "en-US-Studio-O"; // Default voice type
    });
  }

  void _updatePreference(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    if (key == 'audioVolumePreference') {
      _adjustVolume(value);
    }
    _loadPreferences();
  }

  Future<void> _cacheVoiceTypes() async {
    setState(() {
      isCaching = true;
    });
    String phraseToCache = "Hello this is how I sound";
    List<Future> downloadFutures = [];
    for (String voiceType in voiceTypes) {
      downloadFutures.add(_googleTTSUtil
          .downloadMP3(phraseToCache, voiceType)
          .catchError((e) {}));
    }
    await Future.wait(downloadFutures);
    setState(() {
      isCaching = false;
    });
  }

  void _adjustVolume(String volumeLevel) {
    switch (volumeLevel) {
      case 'Low':
        audioPlayer.setVolume(0.2);
      case 'Medium':
        audioPlayer.setVolume(0.6);
      case 'High':
        audioPlayer.setVolume(1.0);
      default:
        audioPlayer.setVolume(0.3);
        break;
    }
  }

  Future<void> _cacheAndNavigate(
      String moduleName, List<AnswerGroup> answerGroups) async {
    if (_voiceType == null) {
      print("Voice type not set. Unable to cache module words.");
      return;
    }

    // Show loading indicator while caching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    // Caching all words
    await cacheUtil.cacheModuleWords(answerGroups, _voiceType!);

    // Check if the widget is still in the tree (mounted) after the async operation
    if (!mounted) return; // Early return if not mounted

    Navigator.pop(context); // Close the loading dialog if still mounted
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleWidget(
          title: moduleName,
          answerGroups: answerGroups,
          isWord: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'Select Difficulties',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Voice Type",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_voicePreference != null) {
                            _googleTTSUtil.speak(
                                "Hello this is how I sound", _voicePreference!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 154, 107, 187),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          child: Text('Test',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children: [
                                SizedBox(height: 10.0),
                                for (int i = 0; i < 4; i++)
                                  ListTile(
                                    title: Text(
                                      voiceTypeTitles[voiceTypes[i]] ?? "",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    leading: Radio<String>(
                                      value: voiceTypes[i],
                                      groupValue: _voicePreference,
                                      onChanged: (String? value) {
                                        _updatePreference(
                                            'voicePreference', value!);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children: [
                                SizedBox(height: 10.0),
                                for (int i = 4; i < 8; i++)
                                  ListTile(
                                    title: Text(
                                      voiceTypeTitles[voiceTypes[i]] ?? "",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    leading: Radio<String>(
                                      value: voiceTypes[i],
                                      groupValue: _voicePreference,
                                      onChanged: (String? value) {
                                        _updatePreference(
                                            'voicePreference', value!);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Background Sound",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_backgroundSound != 'None') {
                          String fileName = _backgroundSound
                              .replaceAll(' Sound', '')
                              .toLowerCase();
                          await audioPlayer.play(
                              AssetSource("audio/background/$fileName.mp3"));
                          await Future.delayed(Duration(seconds: 3));
                          await audioPlayer.stop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 154, 107, 187),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        child: Text('Test',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    'Rain Sound',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  leading: Radio<String>(
                                    value: 'Rain Sound',
                                    groupValue: _backgroundSound,
                                    onChanged: (String? value) {
                                      _updatePreference(
                                          'backgroundSoundPreference', value!);
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    'Shop Sound',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  leading: Radio<String>(
                                    value: 'Shop Sound',
                                    groupValue: _backgroundSound,
                                    onChanged: (String? value) {
                                      _updatePreference(
                                          'backgroundSoundPreference', value!);
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    'None',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  leading: Radio<String>(
                                    value: 'None',
                                    groupValue: _backgroundSound,
                                    onChanged: (String? value) {
                                      _updatePreference(
                                          'backgroundSoundPreference', value!);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'Low',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                leading: Radio<String>(
                                  value: 'Low',
                                  groupValue: _audioVolume,
                                  onChanged: (String? value) {
                                    _updatePreference(
                                        'audioVolumePreference', value!);
                                  },
                                ),
                              ),
                              ListTile(
                                title: AutoSizeText(
                                  'Medium',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                leading: Radio<String>(
                                  value: 'Medium',
                                  groupValue: _audioVolume,
                                  onChanged: (String? value) {
                                    _updatePreference(
                                        'audioVolumePreference', value!);
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'High',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                leading: Radio<String>(
                                  value: 'High',
                                  groupValue: _audioVolume,
                                  onChanged: (String? value) {
                                    _updatePreference(
                                        'audioVolumePreference', value!);
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _cacheAndNavigate(
                                      widget.moduleName, widget.answerGroups);
                                },
                                child: Text('Go to Module'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
