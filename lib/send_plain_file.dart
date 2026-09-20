import 'dart:io';

import 'package:flutter/material.dart';

/// This widget allows sending a plain file over WebSocket without using ffmpeg.
/// It uses the `websocketd` command to read the file in chunks and send it
/// over the WebSocket connection.
class SendPlainFile extends StatefulWidget {
  const SendPlainFile({
    super.key,
    required this.shell,
    required this.onStartProcess,
    required this.onCommandChanged,
  });

  final String shell;
  final VoidCallback onStartProcess;
  final Function(List<String> cmd) onCommandChanged;

  @override
  State<SendPlainFile> createState() => _SendPlainFileState();
}

class _SendPlainFileState extends State<SendPlainFile> {
  List<String> command = [];

  /// ADD HERE YOUR AUDIO FILES with full paths
  List<String> audioPaths = Platform.isWindows
      ? [
          'C:/workspace/libs/flutter_soloud/example/assets/audio/sample-MP3.mp3',
          'C:/workspace/libs/flutter_soloud/example/assets/audio/sample-FLAC.flac',
          'C:/workspace/libs/flutter_soloud/example/assets/audio/sample-OPUS.opus',
          'C:/workspace/libs/flutter_soloud/example/assets/audio/sample-vorbis.ogg',
          'C:/5/8_bit_mentality.mp3',
        ]
      : [
          '/Volumes/NVME/Users/deimos/Music/tests/mp3.mp3',
          '/Volumes/NVME/Users/deimos/Music/tests/flac.flac',
          '/Volumes/NVME/Users/deimos/Music/tests/ogg_opus.ogg',
          '/Volumes/NVME/Users/deimos/Music/tests/ogg_vorbis.ogg',
          '/Volumes/NVME/Users/deimos/Music/tests/ogg_flac.ogg',
        ];
  int audioPathId = 0;
  int sendTimeDelayMs = 100;
  int chunkSize = 16384;

  void composePlainSendFileCommand() {
    command.clear();
    final fr = sendTimeDelayMs / 1000;
    final audioPath = audioPaths[audioPathId];
    final audioFile = File(audioPath);
    final fileSize = audioFile.existsSync() ? audioFile.lengthSync() : 0;
    final numChunks = fileSize > 0 ? (fileSize + chunkSize - 1) ~/ chunkSize : 0;

    // count the number of chunks up-front from the file size, then loop exactly
    // that many times using "dd if=... skip=$i". Once all chunks are sent,
    // the shell exits, websocketd closes the WebSocket, and the
    // receiver’s "onDone" fires.
    command.addAll([
      'websocketd',
      '--port=8080',
      '--binary=true',
      widget.shell,
      '-c',
      'audioPath="$audioPath"; chunkSize=$chunkSize; numChunks=$numChunks; fr=$fr; i=0; while [ \$i -lt $numChunks ]; do dd if="$audioPath" bs=$chunkSize skip=\$i count=1 status=none 2>/dev/null; i=\$((i+1)); sleep $fr; done',
    ]);
    widget.onCommandChanged(command);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      composePlainSendFileCommand();
      widget.onStartProcess();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Send plain file as is without ffmpeg',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<int>(
          value: audioPathId,
          items: List.generate(audioPaths.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(audioPaths[index].split(RegExp(r'[/\\]')).last),
            );
          }),
          onChanged: (value) {
            setState(() {
              audioPathId = value!;
              composePlainSendFileCommand();
              widget.onStartProcess();
            });
          },
        ),
        Slider(
          value: chunkSize.toDouble(),
          min: 1024,
          max: 65536,
          divisions: 64,
          label: chunkSize.toString(),
          onChanged: (value) {
            chunkSize = value.toInt();
            setState(() {});
          },
          onChangeEnd: (value) {
            composePlainSendFileCommand();
            widget.onStartProcess();
          },
        ),
        Slider(
          value: sendTimeDelayMs.toDouble(),
          min: 1,
          max: 1000,
          divisions: 100,
          label: sendTimeDelayMs.toString(),
          onChanged: (value) {
            sendTimeDelayMs = value.toInt();
            setState(() {});
          },
          onChangeEnd: (value) {
            composePlainSendFileCommand();
            widget.onStartProcess();
          },
        ),
        Text('Chunk size: $chunkSize bytes'),
        const SizedBox(height: 8),
        Text('Delay: $sendTimeDelayMs ms'),
      ],
    );
  }
}
