import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'countries.dart';
import 'country.dart';
import 'phone_controller.dart';

class PhoneFormField extends StatefulWidget {
  const PhoneFormField({
    super.key,
    this.controller,
    this.onChanged,
    this.backgroundColor,
    this.inputStyle,
    this.searchStyle,
    this.searchHintText,
    this.decoration,
    this.searchDecoration,
    this.validator,
    this.autovalidateMode,
    this.onSelected,
    this.maxHeight = 256.0,
    this.barrierColor,
  });

  final PhoneController? controller;
  final void Function(String value)? onChanged;
  final TextStyle? inputStyle;
  final TextStyle? searchStyle;
  final InputDecoration? decoration;
  final InputDecoration? searchDecoration;
  final String? searchHintText;
  final Color? backgroundColor;
  final String? Function(String? value)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(Country country)? onSelected;
  final double maxHeight;
  final Color? barrierColor;

  @override
  State<PhoneFormField> createState() => _PhoneFormFieldState();
}

class _PhoneFormFieldState extends State<PhoneFormField> {
  final GlobalKey buttonKey = GlobalKey();
  late final ValueNotifier<Set<Country>> filtered = ValueNotifier(all);

  final PhoneController _innerController = PhoneController();

  PhoneController get controller => widget.controller ?? _innerController;

  Set<Country> get all => Set.from(
        countries.map(
          (item) => Country(
            name: item['country'] ?? '',
            iso: item['iso'] ?? '',
            ddi: item['ddi'] ?? '',
            emoji: item['emoji'] ?? '',
            pattern: item['pattern']?.replaceAll('X', '#') ?? '',
          ),
        ),
      );

  void setSelected(Country country) {
    controller.setSelected(country);
    filtered.value = all;
    widget.onSelected?.call(country);
    return menu?.remove();
  }

  OverlayEntry? menu;

  void setMenu(RelativeRect pos, BoxConstraints constraints) {
    menu = OverlayEntry(
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              if (!kIsWeb)
                Positioned.fill(
                  child: Container(
                    color: widget.barrierColor ?? (Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white54),
                  ),
                ),
              Positioned.fromRect(
                rect: Rect.fromLTRB(
                  pos.left,
                  pos.top - bottom,
                  pos.left + constraints.maxWidth,
                  (pos.top + widget.maxHeight) - bottom,
                ),
                child: TapRegion(
                  onTapOutside: (_) => menu?.remove(),
                  child: Material(
                    color: widget.backgroundColor ?? Colors.white,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxHeight,
                        minHeight: 0.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            autofocus: true,
                            maxLines: 1,
                            style: widget.searchStyle,
                            onChanged: (value) {
                              filtered.value = all.where((c) => removeDiacritics(c.name.toLowerCase()).contains(value.toLowerCase())).toSet();
                            },
                            onFieldSubmitted: (value) {
                              if (filtered.value.isNotEmpty) {
                                return setSelected(filtered.value.first);
                              }
                            },
                            decoration: widget.searchDecoration ??
                                InputDecoration(
                                  fillColor: widget.backgroundColor ?? Colors.white,
                                  filled: true,
                                  border: const OutlineInputBorder(),
                                  hintText: widget.searchHintText ?? 'Pesquisar por nome do país',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                ),
                          ),
                          Flexible(
                            child: ValueListenableBuilder(
                              valueListenable: filtered,
                              builder: (context, value, child) {
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: value.length,
                                  itemBuilder: (context, index) {
                                    final country = value.elementAt(index);

                                    return ListTile(
                                      leading: Text(country.emoji),
                                      title: Text(
                                        country.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () => setSelected(country),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(menu!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return TextFormField(
              controller: controller,
              maxLines: 1,
              minLines: 1,
              style: widget.inputStyle ?? Theme.of(context).textTheme.bodyMedium,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
              keyboardType: TextInputType.phone,
              onChanged: widget.onChanged?.call,
              decoration: widget.decoration?.copyWith(
                    hintText: controller.selected?.pattern.replaceAll('#', '0'),
                    prefixIconConstraints: const BoxConstraints(
                      maxWidth: kMinInteractiveDimension,
                      maxHeight: kMinInteractiveDimension,
                    ),
                    prefixIcon: InkWell(
                      key: buttonKey,
                      canRequestFocus: false,
                      onTap: () async {
                        return setMenu(getPosition(context, buttonKey), constraints);
                      },
                      child: Center(
                        child: Text(controller.selected?.emoji ?? controller.selected?.iso ?? 'N/A'),
                      ),
                    ),
                  ) ??
                  InputDecoration(
                    hintText: controller.selected?.pattern.replaceAll('#', '0'),
                    border: const OutlineInputBorder(),
                    prefixIconConstraints: const BoxConstraints(
                      maxWidth: kMinInteractiveDimension,
                      maxHeight: kMinInteractiveDimension,
                    ),
                    prefixIcon: InkWell(
                      key: buttonKey,
                      canRequestFocus: false,
                      onTap: () async {
                        return setMenu(getPosition(context, buttonKey), constraints);
                      },
                      child: Center(
                        child: Text(controller.selected?.emoji ?? controller.selected?.iso ?? 'N/A'),
                      ),
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  RelativeRect getPosition(BuildContext context, GlobalKey menuKey) {
    final RenderBox button = menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }
}
