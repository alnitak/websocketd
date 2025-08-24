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
  List<String> audioPaths = [
    
  ];
  int audioPathId = 0;
  int sendTimeDelayMs = 100;
  int chunkSize = 16384;

  void composePlainSendFileCommand() {
    //websocketd --port=8080 --binary=true bash -c 'exec 3<"/$audioPath"; while dd bs=1024 count=1 <&3 status=none; do sleep 0.1; done'

    command.clear();
    final fr = sendTimeDelayMs / 1000;

    command.addAll([
      '/bin/bash',
      '-c',
      'websocketd --port=8080 --binary=true ${widget.shell} -c "exec 3<\\"${audioPaths[audioPathId]}\\"; while dd bs=$chunkSize count=1 <&3 status=none; do sleep $fr; done"'
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
              child: Text(audioPaths[index].split('/').last),
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
