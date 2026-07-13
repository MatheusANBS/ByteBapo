import 'package:byte_papo/app/app_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the four persistent destinations and selects one', (
    tester,
  ) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: AppNavigationShell(
          selectedIndex: 0,
          onDestinationSelected: (index) => selectedIndex = index,
          child: const Center(child: Text('Conteudo')),
        ),
      ),
    );

    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Servidores'), findsOneWidget);
    expect(find.text('Modelos'), findsOneWidget);
    expect(find.text('Historico'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    expect(selectedIndex, 0);
  });
}
