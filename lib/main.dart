import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_websocketd/ffmpeg_page.dart';
import 'package:flutter_websocketd/send_plain_file.dart';
import 'package:flutter_websocketd/send_url.dart';
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late LocalProcessManager localProcess;
  late final TabController tabController;
  Process? process;
  String shell = '';
  List<String> command = ['/bin/bash'];
  final commandController = TextEditingController(text: '');
  final outputController = TextEditingController(text: '');

  // final audioPath = 'ADD HERE YOUR AUDIO FILE';
  // final audioPath = '/home/deimos/Music/POP 2005/Blue - Breath Easy.mp3';
  // final audioPath = '/home/deimos/Music/POP 2005/Rolling Stones - A Bigger Bang - Rain Fall Down.mp3';
  // final audioPath = '/home/deimos/FLUTTER/libs/flutter_soloud/example/assets/audio/8_bit_mentality.mp3';
  // final audioPath = '/home/deimos/5/12.-Animal Instinct.flac';
  // final audioPath = '/home/deimos/FLUTTER/libs/flutter_soloud/example/assets/audio/IveSeenThings.mp3';

  // https://dir.xiph.org/codecs
  // final audioPath = 'http://as.fm1.be:8000/wrgm1'; // MP3 streaming radio
  // final audioPath = 'http://xfer.hirschmilch.de:8000/prog-house.opus'; // OPUS streaming radio
  // final audioPath = 'http://superaudio.radio.br:8074/stream'; // OGG streaming radio

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.linux) {
      shell = '/bin/bash';
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      shell = '/bin/zsh';
    }
    killAllWebsocketd();
    localProcess = const LocalProcessManager();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    outputController.dispose();
    killAllWebsocketd();
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

  void killAllWebsocketd() {
    Process.start(shell, ['-c', 'killall -9 websocketd']);
  }

  Widget getChild() {
    if (tabController.index == 0) {
      return FfmpegPage(
        shell: shell,
        onStartProcess: startProcess,
        onCommandChanged: (cmd) {
          command = cmd;
          commandController.text = cmd.join(' ');
        },
      );
    } else if (tabController.index == 1) {
      return SendPlainFile(
        shell: shell,
        onStartProcess: startProcess,
        onCommandChanged: (cmd) {
          command = cmd;
          commandController.text = cmd.join(' ');
        },
      );
    } else {
      return SendUrl(
        shell: shell,
        onStartProcess: startProcess,
        onCommandChanged: (cmd) {
          command = cmd;
          commandController.text = cmd.join(' ');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: tabController,
                onTap: (value) => setState(() {}),
                tabs: const <Widget>[
                  Tab(child: Text('Send using ffmpeg')),
                  Tab(child: Text('Send chunks of plain file')),
                  Tab(child: Text('Send using URL')),
                ],
              ),

              ColoredBox(
                color: const Color.fromARGB(255, 219, 219, 250),
                child: getChild(),
              ),

              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () {
                  outputController.text = '';
                  killAllWebsocketd();
                },
                child: const Text('kill ALL websocketd'),
              ),

              TextField(
                controller: commandController,
                style: const TextStyle(fontSize: 12),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),

              /// OUTPUT
              TextField(
                controller: outputController,
                minLines: 3,
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
      ),
    );
  }
}
