# Kiwi paste dialog patch

This branch is based on the published `pin_code_fields` 8.0.1 source at upstream
commit `607362f86a1ff06e42146148d34116651648ec59`.
The runtime source and manifest were checked against the official pub.dev archive
(SHA-256 `4c0db7fbc889e622e7c71ea54b9ee624bb70c7365b532abea0271b17ea75b729`).

The local patch changes only two methods in `lib/src/pin_code_fields.dart`:

- Remove the question-mark spans appended to the pasted code in both dialogs.
- Inherit `Theme.of(context).textTheme.bodyLarge?.fontFamily` for the title,
  body, pasted code, and action labels. Preserve other supplied text-style values.

The app owns the localized copy and spacing before the code. This fork has no
app-specific theme or localization dependency.

Run `flutter test test/paste_dialog_test.dart` to check Cupertino and Material
dialogs with Inter and Expo, default and custom pasted styles, and both actions.

Both Kiwi apps use this GitHub fork pinned to the same commit. Make future
package edits on `codex/kiwi-paste-dialog`, run the regression tests, push the
change, and update the Git dependency `ref` in both apps to the tested commit.
