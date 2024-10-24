import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process/process.dart';

void main() {
  runApp(const MyApp());
}

/// The channels to be used while initializing the player.
enum Channels {
  /// One channel.
  mono(1),

  /// Two channels.
  stereo(2),

  /// Four channels.
  quad(4),

  /// Six channels.
  surround51(6),

  /// Eight channels.
  dolby71(8);

  const Channels(this.count);

  /// The channels count.
  final int count;

  /// Returns a human-friendly channel name.
  @override
  String toString() {
    switch (this) {
      case Channels.mono:
        return 'Mono';
      case Channels.stereo:
        return 'Stereo';
      case Channels.quad:
        return 'Quad';
      case Channels.surround51:
        return 'Surround 5.1';
      case Channels.dolby71:
        return 'Dolby 7.1';
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'websocketd',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'websocketd'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late LocalProcessManager localProcess;
  Process? process;
  List<String> command = [];
  double nativeFrameRate = 0;
  final sampleRate = [11025, 22050, 44100, 48000];
  final format = ['f32le', 's8', 's16le', 's32le'];
  int srId = 2;
  int chId = 0;
  int fmtId = 0;
  final audioPath = '/home/deimos/5/free/shadertoy/ElectroNebulae.mp3';
  // final audioPath = '/home/deimos/5/12.-Animal Instinct.flac';
  final outputController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    localProcess = const LocalProcessManager();
    composeCommand();
    startProcess();
  }

  @override
  void dispose() {
    outputController.dispose();
    if (process != null) {
      localProcess.killPid(process!.pid);
    }
    super.dispose();
  }

  void startProcess() {
    if (process != null) {
      localProcess.killPid(process!.pid);
    }
    outputController.text = '';

    localProcess.start(runInShell: true, command).then((proc) {
      process = proc;

      process!.stdout.listen((onData) {
        outputController.text += String.fromCharCodes(onData);
      });

      process!.stderr.listen((onData) {
        outputController.text += String.fromCharCodes(onData);
      });
    });
  }

  List<String> composeCommand() {
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
      _ => '',
    };
    command.add('/bin/bash');
    command.add('-c');
    command.add('websocketd --port=8080 --binary=true '
        'ffmpeg '
        '-readrate ${(nativeFrameRate * 10).floorToDouble() / 10} '
        '-i "$audioPath" '
        '-f ${format[fmtId]} $acodec -ac ${Channels.values[chId].count} '
        '-ar ${sampleRate[srId]} -');
    return command;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              composeCommand();
                              startProcess();
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
                              composeCommand();
                              startProcess();
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
                              composeCommand();
                              startProcess();
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),

            OutlinedButton(
              onPressed: () {
                outputController.text = '';
                Process.start('/bin/bash', ['-c', 'killall -9 websocketd']);
              },
              child: const Text('kill ALL websocketd'),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Slider(
                  value: nativeFrameRate,
                  min: 0,
                  max: 4,
                  onChanged: (value) {
                    setState(() {
                      nativeFrameRate = value;
                      composeCommand();
                      startProcess();
                    });
                  },
                ),
                Text('${nativeFrameRate.toStringAsFixed(1)}X    '
                    '1 = real-time speed '
                    'at native frame rate. 0 no limitation on speed'),
              ],
            ),
            const SizedBox(height: 8),

            TextField(
              controller: TextEditingController(text: command.join(' ')),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),

            /// OUTPUT
            TextField(
              controller: outputController,
              maxLines: 12,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                fillColor: Colors.grey[100],
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
