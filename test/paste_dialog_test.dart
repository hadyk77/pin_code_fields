import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            return {'text': ' 12345678 '};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  for (final platform in [PinCodePlatform.iOS, PinCodePlatform.other]) {
    for (final fontFamily in ['Inter', 'Expo']) {
      for (final customStyle in [false, true]) {
        testWidgets(
          '$platform $fontFamily customStyle=$customStyle paste dialog',
          (tester) async {
            final controller = TextEditingController();
            final content = fontFamily == 'Expo'
                ? 'هل تريد لصق هذا الرمز '
                : 'Do you want to paste this code ';
            final style = customStyle
                ? const TextStyle(
                    fontFamily: 'OtherFont',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple,
                  )
                : null;

            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(fontFamily: fontFamily),
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return PinCodeTextField(
                        appContext: context,
                        controller: controller,
                        length: 6,
                        showCursor: false,
                        pastedTextStyle: style,
                        dialogConfig: DialogConfig(
                          platform: platform,
                          dialogTitle: 'Paste code',
                          dialogContent: content,
                          negativeText: 'No',
                          affirmativeText: 'Yes',
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
            await tester.longPress(find.byType(AnimatedContainer).first);
            await tester.pumpAndSettle();

            final dialog = platform == PinCodePlatform.iOS
                ? find.byType(CupertinoAlertDialog)
                : find.byType(AlertDialog);
            expect(dialog, findsOneWidget);
            final bodyFinder = find.descendant(
              of: dialog,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is RichText &&
                    widget.text.toPlainText() == '${content}123456',
              ),
            );
            expect(bodyFinder, findsOneWidget);
            final body = tester.widget<RichText>(bodyFinder).text as TextSpan;
            expect(body.style!.fontFamily, fontFamily);
            expect(body.toPlainText(), isNot(contains('?')));
            final pasted = body.children!.single as TextSpan;
            expect(pasted.style!.fontFamily, fontFamily);
            expect(
              pasted.style!.fontWeight,
              customStyle ? FontWeight.w500 : FontWeight.bold,
            );
            if (customStyle) {
              expect(pasted.style!.fontSize, 18);
              expect(pasted.style!.color, Colors.purple);
            }
            for (final label in ['Paste code', 'No', 'Yes']) {
              final text = tester.widget<Text>(find.text(label));
              expect(text.style!.fontFamily, fontFamily);
            }

            await tester.tap(find.text('No'));
            await tester.pumpAndSettle();
            expect(dialog, findsNothing);
            expect(controller.text, isEmpty);

            await tester.longPress(find.byType(AnimatedContainer).first);
            await tester.pumpAndSettle();
            await tester.tap(find.text('Yes'));
            await tester.pumpAndSettle();
            expect(dialog, findsNothing);
            expect(controller.text, '123456');
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
          },
        );
      }
    }
  }
}
