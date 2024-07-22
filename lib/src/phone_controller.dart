import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:phone_form_field/src/countries.dart';

class PhoneController extends MaskedTextController {
  Country? _selected;

  Country? get selected => _selected;

  void setSelected(Country country) {
    _selected = country;
    clear();
    updateMask(country.pattern);
    notifyListeners();
  }

  PhoneController({
    super.mask = '',
    String? text,
    super.afterChange,
    super.beforeChange,
    super.cursorBehavior,
  }) : super(translator: {'#': RegExp(r'\d')});

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

    final pattern = mask.split('').map(
      (l) {
        if (l == '#') {
          return r'\d';
        } else if (['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(l)) {
          return l;
        } else if (l == ' ') {
          return r'\s';
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
