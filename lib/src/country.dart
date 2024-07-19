class Country {
  final String name;
  final String iso;
  final String ddi;
  final String emoji;
  final String pattern;

  const Country({required this.name, required this.iso, required this.ddi, required this.emoji, required this.pattern});

  static Country defaultCountry() => const Country(name: 'Brasil', iso: 'BR', ddi: '+55', emoji: '🇧🇷', pattern: '+55 00 00000-0000');

  @override
  bool operator ==(covariant Country other) {
    if (identical(this, other)) return true;

    return other.name == name && other.iso == iso && other.ddi == ddi && other.emoji == emoji && other.pattern == pattern;
  }

  @override
  int get hashCode {
    return name.hashCode ^ iso.hashCode ^ ddi.hashCode ^ emoji.hashCode ^ pattern.hashCode;
  }
}
