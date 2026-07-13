import 'package:byte_papo/features/chat/presentation/widgets/message_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders inline and display LaTex without raw delimiters', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageMarkdown(
            data: r'''A area e $A = \pi r^2$.

$$\frac{a}{b}$$''',
            styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );

    expect(find.textContaining(r'$A ='), findsNothing);
    expect(find.text('A area e '), findsOneWidget);
  });
}
