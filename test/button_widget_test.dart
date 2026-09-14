import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';

void main() {
  testWidgets('shared button keeps its appearance and blocks inactive taps',
      (tester) async {
    var taps = 0;
    Future<void> showButton(bool active, {bool externalTap = false}) async {
      final button = ButtonWidget(
        btnTxt: 'Login',
        widthFactor: 0.9,
        height: 52,
        isActive: active,
        onTap: externalTap ? null : () => taps++,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: externalTap
                ? GestureDetector(onTap: () => taps++, child: button)
                : button,
          ),
        ),
      ));
    }

    for (final externalTap in [false, true]) {
      await showButton(false, externalTap: externalTap);
      final label = tester.widget<Text>(find.text('Login'));
      expect(label.style?.color, const Color(0xFFF0EAE6));
      expect(label.style?.fontWeight, FontWeight.w700);
      BoxDecoration decoration() => tester
          .widget<Container>(
            find
                .descendant(
                    of: find.byType(ButtonWidget),
                    matching: find.byType(Container))
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration().color, const Color(0xFF595959));
      final inactiveDecoration = decoration();
      final before = taps;
      await tester.tapAt(tester.getCenter(find.text('Login')));
      expect(taps, before);

      await showButton(true, externalTap: externalTap);
      expect(decoration().color, const Color(0xFF595959));
      expect(decoration(), inactiveDecoration);
      expect(tester.widget<Text>(find.text('Login')).style, label.style);
      await tester.tap(find.text('Login'));
      expect(taps, before + 1);
    }
  });
}
