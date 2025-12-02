import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordPage extends StatefulWidget {
  final int meetingId;
  const VoiceRecordPage({super.key, required this.meetingId});

  @override
  State<VoiceRecordPage> createState() => _VoiceRecordPageState();
}

class _VoiceRecordPageState extends State<VoiceRecordPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderReady = false;
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Request microphone
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      throw Exception("Microphone permission not granted");
    }

    // Request storage
    final storageStatus = await Permission.storage.request();
    if (storageStatus != PermissionStatus.granted) {
      throw Exception("Storage permission not granted");
    }

    await _recorder.openRecorder();
    _isRecorderReady = true;
    setState(() {});
  }
  Future<String> _getDownloadPath() async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory(
        '/storage/emulated/0/Download/Sirapat/voice_record',
      );
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory.path;
  }

  Future<void> _startRecording() async {
    if (!_isRecorderReady) return;

    final downloadPath = await _getDownloadPath();
    final fileName = "voice_${DateTime.now().millisecondsSinceEpoch}.wav";

    final fullPath = "$downloadPath/$fileName";

    await _recorder.startRecorder(toFile: fullPath, codec: Codec.pcm16WAV);

    _filePath = fullPath;

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderReady) return;

    await _recorder.stopRecorder();

    setState(() {
      _isRecording = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Saved to:\n$_filePath")));
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Recorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isRecording ? 180 : 80,
              width: 180,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.redAccent : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              _isRecording ? "Recording..." : "Tap to start recording",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                _isRecording ? _stopRecording() : _startRecording();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _isRecording ? Colors.red : Colors.blueAccent,
              ),
              child: Text(
                _isRecording ? "Stop" : "Record",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 40),

            if (_filePath != null)
              Column(
                children: [
                  const Text("Last recording:"),
                  Text(
                    _filePath!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
