import 'package:flutter/material.dart';

import 'model.dart';

class CustomForm extends StatefulWidget {
  final Map<String, dynamic> config;
  final Map<String, dynamic>? initialValue;
  final Future<DateTime?> Function(DateTime?)? onDatePicker;
  final String? Function(DateTime?)? dateFormatter;
  final Future<DropdownModel?> Function(List<DropdownModel> data, DropdownModel? selected)? onDropdownPicker;
  final void Function(Map<String, dynamic>)? onSave;

  const CustomForm({
    super.key,
    required this.config,
    this.initialValue,
    this.onSave,
    this.onDatePicker,
    this.dateFormatter,
    this.onDropdownPicker,
  });

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialValue?.toObject(widget.config) ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          ...widget.config.entries.map((entry) {
            final entryValue = entry.value;
            final fieldCode = entry.key;

            final fieldType = FieldType.values
                .firstWhere((element) => element.value == entryValue['type'], orElse: () => FieldType.unknown);
            switch (fieldType) {
              case FieldType.text:
                return TextFormField(
                  initialValue: _data[fieldCode],
                  onSaved: (value) => _data[fieldCode] = value ?? '',
                );
              case FieldType.datetime:
                return PickerTextFormField(
                  initialValue: widget.dateFormatter?.call(_data[fieldCode]) ?? _data[fieldCode]?.toIso8601String(),
                  onTap: () async {
                    final result = await widget.onDatePicker?.call(_data[fieldCode]);
                    if (result == null) return null;

                    _data[fieldCode] = result;
                    return widget.dateFormatter?.call(result) ?? result.toIso8601String();
                  },
                );
              case FieldType.dropdown:
                final listData = entryValue['list']?.entries?.map<DropdownModel>((e) => DropdownModel(code: e.key, label: e.value['label'])).toList() ?? <DropdownModel>[];
                return PickerTextFormField(
                  initialValue: (_data[fieldCode] as DropdownModel?)?.label,
                  onTap: () async {
                    final result = await widget.onDropdownPicker?.call(listData, _data[fieldCode]);
                    if (result == null) return null;

                    _data[fieldCode] = result;
                    return result.label;
                  },
                );
              case FieldType.unknown:
                return const SizedBox();
            }
          }).toList(),
          ElevatedButton(
            onPressed: () {
              formKey.currentState?.save();
              widget.onSave?.call(_data.toValue(dateFormatter: widget.dateFormatter));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class PickerTextFormField extends StatefulWidget {
  final String? initialValue;
  final Future<String?> Function() onTap;

  const PickerTextFormField({
    super.key,
    this.initialValue,
    required this.onTap,
  });

  @override
  State<PickerTextFormField> createState() => _PickerTextFormFieldState();
}

class _PickerTextFormFieldState extends State<PickerTextFormField> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () async {
        final result = await widget.onTap.call();
        if (result != null) {
          _controller?.text = result;
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

extension on Map<String, dynamic> {
  Map<String, dynamic> toObject(Map<String, dynamic> config) {
    final newMap = <String, dynamic>{};
    for (var info in entries) {
      final key = info.key;
      // skip if key not found in config
      // if (config.containsKey(key) != true) continue;
      final configValue = config[key];

      // get input field type
      final fieldType = FieldType.values
          .firstWhere((element) => element.value == configValue?['type'], orElse: () => FieldType.unknown);

      // parse to object
      final value = info.value;
      switch (fieldType) {
        case FieldType.text:
          newMap[key] = value;
        case FieldType.datetime:
          newMap[key] = DateTime.tryParse(value);
        case FieldType.dropdown:
          if (configValue?['list']?.containsKey(value) == true) {
            newMap[key] = DropdownModel(code: value, label: configValue!['list']![value]?['label']);
          }
        case FieldType.unknown:
          newMap[key] = value;
      }
    }
    return newMap;
  }

  Map<String, dynamic> toValue({String? Function(DateTime?)? dateFormatter}) {
    return map((key, value) {
      if (value is DateTime) return MapEntry(key, dateFormatter?.call(value) ?? value.toIso8601String());
      if (value is DropdownModel) return MapEntry(key, value.code);

      return MapEntry(key, value);
    });
  }
}
