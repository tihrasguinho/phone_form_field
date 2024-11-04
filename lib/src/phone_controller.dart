import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:phone_form_field/src/countries.dart';

class PhoneController extends MaskedTextController {
  Country? _selected = const Country(
    name: 'Brasil',
    iso: 'BR',
    ddi: '+55',
    emoji: '🇧🇷',
    pattern: '+55 ## #####-####',
  );

  Country? get selected => _selected;

  void setSelected(Country country) {
    _selected = country;
    clear();
    updateMask(country.pattern);
    notifyListeners();
  }

  PhoneController({
    super.mask = '+55 ## #####-####',
    String? text,
    super.afterChange,
    super.beforeChange,
    super.cursorBehavior,
  }) : super(translator: {'#': RegExp(r'\d')}) {
    if (text != null) {
      updateValue(text);
    }
  }

  void updateValue(String? value) {
    if (value == null) return;
    final match = RegExp(r'(\+[\d]+\s)').firstMatch(value);
    if (match == null) return;
    final ddi = match.group(1);
    final index = countries.indexWhere((c) => c['ddi'] == ddi?.trim());
    if (index == -1) return;
    final country = countries[index];
    _selected = Country(
      name: country['country'] ?? '',
      iso: country['iso'] ?? '',
      ddi: country['ddi'] ?? '',
      emoji: country['emoji'] ?? '',
      pattern: country['pattern']?.replaceAll('X', '#') ?? '',
    );
    updateMask(_selected?.pattern ?? '');
    updateText(value);
  }

  String? maskValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'empty';
    }

    final pattern = mask.replaceAllMappedIndexed(
      RegExp(r'(#)\1+'),
      (index, match) {
        final length = match.group(0)?.length ?? 0;

        if (mask.startsWith('+55')) {
          if (index == 1 || index == 2) {
            return '[\\d]{${length - 1},$length}';
          } else {
            return '[\\d]{$length}';
          }
        } else {
          return '[\\d]{$length}';
        }
      },
    );

    final regex = RegExp('^\\$pattern\$');

    if (!regex.hasMatch(value)) {
      return 'invalid';
    } else {
      return null;
    }
  }
}

extension _String on String {
  String? replaceAllMappedIndexed(
    RegExp pattern,
    String Function(int index, Match match) func,
  ) {
    int index = 0;
    return replaceAllMapped(pattern, (match) => func(index++, match));
  }
}
