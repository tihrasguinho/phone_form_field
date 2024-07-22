import 'package:extended_masked_text/extended_masked_text.dart';

class PhoneController extends MaskedTextController {
  PhoneController({
    super.mask = '+55 00 00000-0000',
    super.text,
    super.afterChange,
    super.beforeChange,
    super.cursorBehavior,
  });

  String? maskValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'empty';
    }

    final pattern = mask.split('').map(
      (l) {
        if (['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(l)) {
          return r'\d';
        } else {
          return '\\$l';
        }
      },
    );

    final regex = RegExp('^${pattern.join()}\$');

    if (!regex.hasMatch(value)) {
      return 'invalid';
    } else {
      return null;
    }
  }
}
