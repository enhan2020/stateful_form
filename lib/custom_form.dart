import 'package:flutter/material.dart';

import 'model.dart';

class CustomForm extends StatefulWidget {
  final Contact? initialValue;
  final Future<DateTime?> Function(DateTime?)? onDatePicker;
  final String? Function(DateTime?)? dateFormatter;
  final List<Country>? countryList;
  final Future<Country?> Function(List<Country> data, Country? selected)? onCountryPicker;
  final void Function(Contact)? onSave;

  const CustomForm({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.onDatePicker,
    this.dateFormatter,
    this.countryList,
    this.onCountryPicker,
  });

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final formKey = GlobalKey<FormState>();
  String? _name;
  DateTime? _dob;
  Country? _country;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _name = widget.initialValue!.name;
      _dob = widget.initialValue!.dob;
      _country = widget.initialValue!.country;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _name,
            onSaved: (value) => _name = value ?? '',
          ),
          PickerTextFormField(
            initialValue: widget.dateFormatter?.call(_dob) ?? _dob!.toIso8601String(),
            onTap: () async {
              final result = await widget.onDatePicker?.call(_dob);
              if (result == null) return null;

              _dob = result;
              return widget.dateFormatter?.call(_dob) ?? _dob!.toIso8601String();
            },
          ),
          PickerTextFormField(
            initialValue: _country?.label,
            onTap: () async {
              final result = await widget.onCountryPicker?.call(widget.countryList ?? [], _country);
              if (result == null) return null;

              _country = result;
              return _country!.label;
            },
          ),
          ElevatedButton(
            onPressed: () {
              formKey.currentState?.save();
              widget.onSave?.call(
                Contact(
                  name: _name,
                  dob: _dob,
                  country: _country,
                ),
              );
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