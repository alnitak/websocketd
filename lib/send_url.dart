import 'package:flutter/material.dart';

class SendUrl extends StatefulWidget {
  const SendUrl({
    super.key,
    required this.shell,
    required this.onStartProcess,
    required this.onCommandChanged,
  });

  final String shell;
  final VoidCallback onStartProcess;
  final Function(List<String> cmd) onCommandChanged;

  @override
  State<SendUrl> createState() => _SendUrlState();
}

class _SendUrlState extends State<SendUrl> {
  List<String> command = [];

  /// ADD HERE YOUR URLS
  // https://dir.xiph.org/codecs
  List<Map<String, String>> audioUrls = [
    // MP3 streaming radio
    {'MP3': 'http://as.fm1.be:8000/wrgm1'},
    // OPUS streaming radio
    {'OPUS': 'http://xfer.hirschmilch.de:8000/prog-house.opus'},
    // OGG streaming radio
    {'OGG': 'http://superaudio.radio.br:8074/stream'},
  ];
  int audioUrlId = 0;

  void composeUrlCommand() {
    // /bin/bash -c 'websocketd --port=8080 --binary=true /bin/bash -c "curl --no-buffer -s http://example.com/stream"'

    command.clear();
    double nativeFrameRate = 0.1;
    double fr = (nativeFrameRate * 100).floorToDouble() / 100;
    if (fr == 0) {
      fr = 0.01;
    }

    command.addAll([
      '/bin/bash',
      '-c',
      'websocketd --port=8080 --binary=true ${widget.shell} -c "curl --no-buffer -s ${audioUrls[audioUrlId].values.first}"'
    ]);
    widget.onCommandChanged(command);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      composeUrlCommand();
      widget.onStartProcess();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            DropdownButton(
              value: audioUrlId,
              items: List.generate(audioUrls.length, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Row(
                    children: [
                      Text(
                        audioUrls[index].keys.first,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(' - ${audioUrls[index].values.first}'),
                    ],
                  ),
                );
              }),
              onChanged: (value) {
                audioUrlId = value ?? 0;
                composeUrlCommand();
                widget.onCommandChanged(command);
                widget.onStartProcess();
                if (context.mounted) {
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
