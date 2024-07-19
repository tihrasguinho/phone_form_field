import 'package:extended_masked_text/extended_masked_text.dart';

class PhoneController extends MaskedTextController {
  PhoneController({
    super.mask = '+55 00 00000-0000',
    super.text,
    super.afterChange,
    super.beforeChange,
    super.cursorBehavior,
  });
}
