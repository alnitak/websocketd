import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process/process.dart';

void main() {
  runApp(const MyApp());
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
  bool nativeFrameRate = true;
  final codec = ['mp3', 'flac', 'ogg', 'wav', 'pcm'];
  final sampleRate = [11025, 22050, 44100, 48000];
  final channels = [1, 2];
  final format = ['f32le', 's8', 's16le', 's32le'];
  int codecId = 4;
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
    // The FFmpeg's "-re" flag means to "Read input at native frame rate"
    command.clear();
    if (codec[codecId] == 'pcm') {
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
          '${nativeFrameRate ? '-re ' : ''} '
          '-i "$audioPath" '
          '-f ${format[fmtId]} $acodec -ac ${channels[chId]} '
          '-ar ${sampleRate[srId]} -');
    } else {
      final f = switch (codecId) {
        0 => '-f mp3',
        1 => '-f flac',
        2 => '-f ogg',
        3 => '-f wav',
        _ => '',
      };
      command.add('/bin/bash');
      command.add('-c');
      command.add('websocketd --port=8080 --binary=true '
          'ffmpeg '
          '${nativeFrameRate ? '-re ' : ''} '
          '-i "$audioPath" '
          '$f -');
    }
    return command;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('websocketd'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CODEC
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < codec.length; i++)
                      SizedBox(
                        width: 160,
                        child: RadioListTile<int>(
                          title: Text(codec[i]),
                          value: i,
                          groupValue: codecId,
                          onChanged: (value) {
                            setState(() {
                              codecId = value!;
                              composeCommand();
                              startProcess();
                            });
                          },
                        ),
                      ),
                  ],
                ),

                /// SAMPLERATE
                if (codec[codecId] == 'pcm')
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
                if (codec[codecId] == 'pcm')
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < channels.length; i++)
                        SizedBox(
                          width: 160,
                          child: RadioListTile<int>(
                            title: Text(channels[i].toString()),
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
                if (codec[codecId] == 'pcm')
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

            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    outputController.text = '';
                    Process.start('/bin/bash', ['-c', 'killall -9 websocketd']);
                  },
                  child: const Text('kill ALL websocketd'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      command.clear();
                      command.add('/bin/bash');
                      command.add('-c');
                      command.add('websocketd --port=8080 --binary=true '
                        'cat /home/deimos/pppppp_44100_1_s8.pcm');
                      startProcess();
                    });
                  },
                  child: const Text('cat pppppp_44100_1_s8.pcm'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      command.clear();
                      command.add('/bin/bash');
                      command.add('-c');
                      command.add('websocketd --port=8080 --binary=true '
                        'cat /home/deimos/ppppp_44100_s16_1.pcm');
                      startProcess();
                    });
                  },
                  child: const Text('cat ppppp_44100_s16_1.pcm'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      command.clear();
                      command.add('/bin/bash');
                      command.add('-c');
                      command.add('websocketd --port=8080 --binary=true '
                        'cat /home/deimos/pppppp_f32_1_44100.pcm');
                      startProcess();
                    });
                  },
                  child: const Text('cat pppppp_f32_1_44100.pcm'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      command.clear();
                      command.add('/bin/bash');
                      command.add('-c');
                      command.add('websocketd --port=8080 --binary=true '
                        'cat /home/deimos/ppppppp.flac');
                      startProcess();
                    });
                  },
                  child: const Text('cat ppppppp.flac'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: nativeFrameRate,
                  onChanged: (value) {
                    setState(() {
                      nativeFrameRate = value;
                      startProcess();
                    });
                  },
                ),
                const Text('Read input at native frame rate'),
              ],
            ),
            const SizedBox(height: 8),

            TextField(
              controller: TextEditingController(text: command.join(' ') ?? ''),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),

            /// OUTPUT
            TextField(
              controller: outputController,
              maxLines: 10,
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
