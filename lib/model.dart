enum FieldType {
  text('text'),
  datetime('datetime'),
  dropdown('dropdown'),
  unknown('unknown');

  const FieldType(this.value);

  final String value;
}

class DropdownModel {
  final String code;
  final String label;

  const DropdownModel({required this.code, required this.label});

  factory DropdownModel.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String;
    final label = json['label'] as String;
    return DropdownModel(code: code, label: label);
  }
}
