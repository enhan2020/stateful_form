class Contact {
  final String? name;
  final DateTime? dob;
  final Country? country;

  const Contact({
    this.name,
    this.dob,
    this.country,
  });

  @override
  String toString() {
    return 'name: $name, dob: ${dob?.toIso8601String()}, country: ${country?.label}(${country?.code})';
  }
}

class Country {
  final String code;
  final String label;

  const Country({required this.code, required this.label});
}
