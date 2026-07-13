import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;

class MessageMarkdown extends StatelessWidget {
  const MessageMarkdown({
    required this.data,
    required this.styleSheet,
    super.key,
  });

  final String data;
  final MarkdownStyleSheet styleSheet;

  @override
  Widget build(BuildContext context) => MarkdownBody(
    data: data,
    selectable: true,
    softLineBreak: true,
    styleSheet: styleSheet,
    builders: {'latex': LatexElementBuilder(textStyle: styleSheet.p)},
    extensionSet: md.ExtensionSet([LatexBlockSyntax()], [LatexInlineSyntax()]),
  );
}
