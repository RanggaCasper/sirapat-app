import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/audio_repository.dart';
import 'package:sirapat_app/data/models/audio_transcript_model.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class VoiceRecordPage extends StatefulWidget {
  final int meetingId;
  const VoiceRecordPage({super.key, required this.meetingId});

  @override
  State<VoiceRecordPage> createState() => _VoiceRecordPageState();
}

class _VoiceRecordPageState extends State<VoiceRecordPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioRepository _audioRepository = Get.find<AudioRepository>();
  final NotificationController _notif = Get.find<NotificationController>();
  final TextEditingController _transcriptController = TextEditingController();

  bool _isRecorderReady = false;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isProcessing = false;
  String? _filePath;
  AudioTranscriptModel? _transcript;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  AudioTranscriptModel? _recordTranscript;
  String? _transcriptError;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      // Request microphone
      final micStatus = await Permission.microphone.request();
      if (micStatus != PermissionStatus.granted) {
        _notif.showError("Izin mikrofon tidak diberikan");
        return;
      }

      // Request storage permissions based on Android version
      if (Platform.isAndroid) {
        // For Android 13 (API 33) and above, use different permissions
        if (await Permission.photos.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted ||
            await Permission.storage.request().isGranted) {
          // At least one storage permission granted
        } else {
          _notif.showWarning(
            'Izin penyimpanan tidak diberikan. Rekaman akan disimpan di direktori aplikasi.',
          );
        }
      }

      await _recorder.openRecorder();
      _isRecorderReady = true;
      setState(() {});
    } catch (e) {
      _notif.showError('Gagal menginisialisasi perekam: $e');
      debugPrint('Error initializing recorder: $e');
    }
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
    if (!_isRecorderReady) {
      _notif.showError('Perekam belum siap');
      return;
    }

    try {
      final downloadPath = await _getDownloadPath();
      final fileName = "voice_${DateTime.now().millisecondsSinceEpoch}.wav";
      final fullPath = "$downloadPath/$fileName";

      debugPrint('Starting recording to: $fullPath');

      await _recorder.startRecorder(
        toFile: fullPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );

      _filePath = fullPath;
      _recordDuration = Duration.zero;
      _startTimer();

      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
    } catch (e) {
      _notif.showError('Gagal memulai perekaman: $e');
      debugPrint('Error starting recording: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _recordDuration = Duration(seconds: _recordDuration.inSeconds + 1);
        });
      }
    });
  }

  Future<void> _pauseRecording() async {
    if (!_isRecorderReady || !_isRecording) return;

    await _recorder.pauseRecorder();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    if (!_isRecorderReady || !_isRecording) return;

    await _recorder.resumeRecorder();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderReady) return;

    try {
      await _recorder.stopRecorder();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      debugPrint('Recording saved to: $_filePath');
      _notif.showSuccess(
        'Rekaman tersimpan: ${_formatDuration(_recordDuration)}',
      );
    } catch (e) {
      _notif.showError('Gagal menghentikan perekaman: $e');
      debugPrint('Error stopping recording: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isProcessing = true);

        File file = File(result.files.single.path!);
        final fileSize = await file.length();

        debugPrint('Uploading file: ${file.path}');
        debugPrint(
          'File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );

        final transcript = await _audioRepository.uploadAndTranscribeAudio(
          file,
        );

        debugPrint(
          'Transcription received: ${transcript.text.length} characters',
        );

        setState(() {
          _transcript = transcript;
          _transcriptController.text = transcript.text;
          _isProcessing = false;
        });

        _notif.showSuccess('Audio berhasil ditranskripsi');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      setState(() => _isProcessing = false);
      _notif.showError('Gagal mengunggah audio: $e');
    }
  }

  Future<void> _uploadRecordedFile() async {
    if (_filePath == null) {
      setState(() {
        _transcriptError = 'File rekaman tidak ditemukan';
      });
      return;
    }
    setState(() {
      _transcriptError = null;
    });

    try {
      setState(() => _isProcessing = true);

      File file = File(_filePath!);

      if (!await file.exists()) {
        throw Exception('File rekaman tidak ditemukan');
      }

      final fileSize = await file.length();
      debugPrint('Uploading recorded file: $_filePath');
      debugPrint(
        'File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      final transcript = await _audioRepository.uploadAndTranscribeAudio(file);

      debugPrint(
        'Transcription received: ${transcript.text.length} characters',
      );

      setState(() {
        _recordTranscript = transcript;
        _transcript = transcript;
        _transcriptController.text = transcript.text;
        _isProcessing = false;
        _transcriptError = null;
      });

      _notif.showSuccess('Rekaman berhasil ditranskripsi');
    } catch (e) {
      debugPrint('Upload recorded file error: $e');
      setState(() => _isProcessing = false);
      _notif.showError('Gagal mentranskripsikan rekaman: $e');
    }
  }

  Future<void> _createMeetingMinutes() async {
    if (_transcriptController.text.trim().isEmpty) {
      setState(() {
        _transcriptError = 'Silakan berikan teks transkrip';
      });
      return;
    }
    setState(() {
      _transcriptError = null;
    });

    try {
      setState(() => _isProcessing = true);

      debugPrint(
        'Creating meeting minutes for meeting ID: ${widget.meetingId}',
      );
      debugPrint('Text length: ${_transcriptController.text.length}');

      await _audioRepository.createMeetingMinutes(
        text: _transcriptController.text,
        meetingId: widget.meetingId,
        style: 'detailed',
        includeElements: true,
      );

      debugPrint('Meeting minutes created successfully');

      setState(() => _isProcessing = false);

      _notif.showSuccess('Notulen rapat berhasil dibuat');

      // Navigate back after success
      Get.back();
    } catch (e) {
      debugPrint('Create meeting minutes error: $e');
      setState(() => _isProcessing = false);
      _notif.showError('Gagal membuat notulen rapat: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asisten Rapat"),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Recording Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _isRecording ? 120 : 80,
                            width: _isRecording ? 120 : 80,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? Colors.redAccent
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              _isRecording ? Icons.mic : Icons.mic_none,
                              size: 50,
                              color: _isRecording
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isRecording
                                ? (_isPaused ? "Dijeda" : "Merekam...")
                                : "Rekam Audio Rapat",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isRecording) ...[
                            const SizedBox(height: 8),
                            Text(
                              _formatDuration(_recordDuration),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _isPaused ? Colors.orange : Colors.red,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isRecording)
                                ElevatedButton.icon(
                                  onPressed: _startRecording,
                                  icon: const Icon(Icons.mic),
                                  label: const Text(
                                    "Mulai Merekam",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              if (_isRecording) ...[
                                ElevatedButton.icon(
                                  onPressed: _isPaused
                                      ? _resumeRecording
                                      : _pauseRecording,
                                  icon: Icon(
                                    _isPaused ? Icons.play_arrow : Icons.pause,
                                  ),
                                  label: Text(_isPaused ? "Lanjutkan" : "Jeda"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _stopRecording,
                                  icon: const Icon(Icons.stop),
                                  label: const Text("Berhenti"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_filePath != null) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Rekaman tersimpan (${_formatDuration(_recordDuration)})",
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _uploadRecordedFile,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text("Transkripsi Rekaman"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (_recordTranscript != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.description,
                                          size: 16,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Transkrip Recording",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _recordTranscript!.text,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade800,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upload File Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 50,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Unggah File Audio",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Format yang didukung: MP3, WAV, M4A, AAC",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickAndUploadFile,
                            icon: const Icon(Icons.folder_open),
                            label: const Text(
                              "Pilih File",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Transcript Section
                  if (_transcript != null) ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.article, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  "Transcript",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.audiotrack,
                                        size: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Durasi: ${_transcript!.audioInfo.duration.toStringAsFixed(1)}d",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.timer,
                                        size: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Proses: ${_transcript!.processingTime.toStringAsFixed(2)}d",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Transcript Editor
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.edit_note, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                "Transkrip",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _transcriptController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              hintText: _transcript == null
                                  ? "Unggah atau rekam audio untuk mendapatkan transkrip, atau ketik secara manual..."
                                  : "Ubah transkrip jika diperlukan...",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              errorText: _transcriptError,
                              errorMaxLines: 2,
                            ),
                            onChanged: (value) {
                              if (_transcriptError != null) {
                                setState(() {
                                  _transcriptError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _createMeetingMinutes,
                              icon: const Icon(Icons.description),
                              label: const Text("Buat Notulen Rapat"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
