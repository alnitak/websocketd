import 'package:flutter/material.dart';
import 'package:flutter_websocketd/enums.dart';

/// Use the ffmpeg command to convert audio files
/// to a format suitable for streaming over WebSocket.
/// The command is composed based on the selected options.
/// The options include sample rate, channels, format, and whether to strip metadata.
/// The command is executed when the user interacts with the UI,
/// and the output is displayed in a text field.
/// The user can also adjust the native frame rate for input speed control.
class FfmpegPage extends StatefulWidget {
  const FfmpegPage({
    super.key,
    required this.shell,
    required this.onStartProcess,
    required this.onCommandChanged,
  });

  final String shell;
  final VoidCallback onStartProcess;
  final Function(List<String> cmd) onCommandChanged;

  @override
  State<FfmpegPage> createState() => _FfmpegPageState();
}

class _FfmpegPageState extends State<FfmpegPage> {
  List<String> command = [];
  double nativeFrameRate = 0;
  // Supported Opus sample rates:
  final sampleRate = [8000, 12000, 16000, 24000, 44100, 48000];
  final format = ['f32le', 's8', 's16le', 's32le', 'opus', 'mp3'];
  int srId = 5;
  int chId = 0;
  int fmtId = 5;
  bool stripMetaData = true;

  /// ADD HERE YOUR AUDIO FILES with full paths
  List<String> audioPaths = [
  ];
  int audioPathId = 0;

  List<String> composeFfmpegCommand() {
    // -readrate speed (input)
    // Limit input read speed.
    // Its value is a floating-point positive number which represents the
    // maximum duration of media, in seconds, that should be ingested in
    // one second of wallclock time. Default value is zero and represents
    // no imposed limitation on speed of ingestion. Value 1 represents real-time
    // speed and is equivalent to -re.
    // Mainly used to simulate a capture device or live input stream
    // (e.g. when reading from a file). Should not be used with a low value
    // when input is an actual capture device or live stream as it may cause
    // packet loss.
    // It is useful for when flow speed of output packets is important,
    // such as live streaming.
    //
    // 5 will ingest 5 seconds of media data in one second

    command.clear();
    final acodec = switch (fmtId) {
      0 => '-acodec pcm_f32le',
      1 => '',
      2 => '-acodec pcm_s16le',
      3 => '-acodec pcm_s32le',
      4 => '-acodec libopus',
      5 => '-acodec libmp3lame',
      _ => '',
    };

    final sm = stripMetaData ? '-map_metadata -1 -vn' : '';

    // /bin/bash -c websocketd --port=8080 --binary=true ffmpeg -loglevel error
    // -readrate 0.0 -i "/home/deimos/5/12.-Animal Instinct.flac" -map_metadata
    // -1 -vn -f mp3 -acodec libmp3lame -ac 1 -ar 48000 -application audio -
    command.add(widget.shell);
    command.add('-c');
    command.add('websocketd --port=8080 --binary=true '
        'ffmpeg '
        '-loglevel error '
        '-readrate ${(nativeFrameRate * 100).floorToDouble() / 100} '
        '-i "${audioPaths[audioPathId]}" '
        '$sm ' // strip metadata and video
        '-f ${format[fmtId]} $acodec -ac ${Channels.values[chId].count} '
        '-ar ${sampleRate[srId]} -application audio -');
    widget.onCommandChanged(command);
    return command;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      composeFfmpegCommand();
      widget.onStartProcess();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
              composeFfmpegCommand();
              widget.onStartProcess();
            });
          },
        ),
        Row(
          children: [
            /// SAMPLERATE
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < sampleRate.length; i++)
                  SizedBox(
                    width: 160,
                    child: RadioListTile<int>(
                      title: Text(sampleRate[i].toString()),
                      value: i,
                      groupValue: srId,
                      onChanged: (int? value) {
                        setState(() {
                          srId = value!;
                          composeFfmpegCommand();
                          widget.onStartProcess();
                        });
                      },
                    ),
                  ),
              ],
            ),

            /// CHANNELS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < Channels.values.length; i++)
                  SizedBox(
                    width: 210,
                    child: RadioListTile<int>(
                      title: Text(Channels.values[i].toString()),
                      value: i,
                      groupValue: chId,
                      onChanged: (int? value) {
                        setState(() {
                          chId = value!;
                          composeFfmpegCommand();
                          widget.onStartProcess();
                        });
                      },
                    ),
                  ),
              ],
            ),

            /// FORMAT
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < format.length; i++)
                  SizedBox(
                    width: 160,
                    child: RadioListTile<int>(
                      title: Text(format[i]),
                      value: i,
                      groupValue: fmtId,
                      onChanged: (int? value) {
                        setState(() {
                          fmtId = value!;
                          composeFfmpegCommand();
                          widget.onStartProcess();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: stripMetaData,
              onChanged: (value) {
                setState(() {
                  stripMetaData = !stripMetaData;
                  composeFfmpegCommand();
                  widget.onStartProcess();
                });
              },
            ),
            const Text('strip metaData'),
          ],
        ),
        Row(
          children: [
            Slider(
              value: nativeFrameRate,
              min: 0,
              max: 10,
              label: nativeFrameRate.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  nativeFrameRate = value;
                });
              },
              onChangeEnd: (value) {
                composeFfmpegCommand();
                widget.onStartProcess();
              },
            ),
            Text('${nativeFrameRate.toStringAsFixed(2)}X    '
                '1 = real-time speed '
                'at native frame rate. 0 no limitation on speed'),
          ],
        ),
      ],
    );
  }
}