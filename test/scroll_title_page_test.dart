import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/widgets/custom_appbar.dart';
import 'package:mindfully_evolve_app/common/widgets/scroll_title_page.dart';

void main() {
  testWidgets('large page title appears in fixed header and hides at the top',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ScrollTitlePage(
          title: 'Favorite Meditations',
          child: Column(children: [
            const CustomAppbar(headingTxt: ''),
            Expanded(
              child: ListView(
                controller: controller,
                children: const [
                  Text('Favorite Meditations'),
                  SizedBox(height: 1600),
                ],
              ),
            ),
          ]),
        ),
      ),
    ));

    final header = find.byType(CustomAppbar);
    final opacity =
        find.descendant(of: header, matching: find.byType(AnimatedOpacity));
    expect(tester.widget<AnimatedOpacity>(opacity).opacity, 0);
    final originalPosition = tester.getTopLeft(header);

    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(opacity).opacity, 1);
    expect(tester.getTopLeft(header), originalPosition);
    final title = find.descendant(
        of: header, matching: find.text('Favorite Meditations'));
    expect(tester.getCenter(title).dx, tester.getCenter(header).dx);

    controller.jumpTo(0);
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(opacity).opacity, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('existing static headers remain visible', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: CustomAppbar(headingTxt: 'Notifications')),
    ));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
