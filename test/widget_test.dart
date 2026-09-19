import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_websocketd/ffmpeg_page.dart';

void main() {
  testWidgets('FfmpegPage renders all formats and generates correct commands',
      (WidgetTester tester) async {
    List<String> lastCommand = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FfmpegPage(
              shell: '/bin/zsh',
              onStartProcess: () {},
              onCommandChanged: (cmd) {
                lastCommand = cmd;
              },
            ),
          ),
        ),
      ),
    );

    // Verify newly added formats are rendered
    expect(find.text('aac'), findsOneWidget);
    expect(find.text('m4a'), findsOneWidget);
    expect(find.text('mp4'), findsOneWidget);
    expect(find.text('ac3'), findsOneWidget);
    expect(find.text('eac3'), findsOneWidget);

    // Tap on 'aac'
    await tester.tap(find.text('aac'));
    await tester.pumpAndSettle();
    expect(lastCommand.join(' '), contains('-f adts -acodec aac'));

    // Tap on 'm4a'
    await tester.tap(find.text('m4a'));
    await tester.pumpAndSettle();
    expect(lastCommand.join(' '),
        contains('-f ipod -movflags frag_keyframe+empty_moov -acodec aac'));

    // Tap on 'mp4'
    await tester.tap(find.text('mp4'));
    await tester.pumpAndSettle();
    expect(lastCommand.join(' '),
        contains('-f mp4 -movflags frag_keyframe+empty_moov -acodec aac'));

    // Tap on 'ac3'
    await tester.tap(find.text('ac3'));
    await tester.pumpAndSettle();
    expect(lastCommand.join(' '), contains('-f ac3 -acodec ac3'));

    // Tap on 'eac3'
    await tester.tap(find.text('eac3'));
    await tester.pumpAndSettle();
    expect(lastCommand.join(' '), contains('-f eac3 -acodec eac3'));
  });
}
