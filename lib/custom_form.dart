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
  Contact? _data;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _data = widget.initialValue;
    }

    _data ??= Contact();
  }

  @override
  void didUpdateWidget(covariant CustomForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _data = widget.initialValue;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _data?.name,
            onSaved: (value) => _data?.name = value ?? '',
          ),
          PickerTextFormField(
            initialValue: widget.dateFormatter?.call(_data?.dob) ?? _data?.dob!.toIso8601String(),
            onTap: () async {
              final result = await widget.onDatePicker?.call(_data?.dob);
              if (result == null) return null;

              _data?.dob = result;
              return widget.dateFormatter?.call(_data?.dob) ?? _data?.dob!.toIso8601String();
            },
          ),
          PickerTextFormField(
            initialValue: _data?.country?.label,
            onTap: () async {
              final result = await widget.onCountryPicker?.call(widget.countryList ?? [], _data?.country);
              if (result == null) return null;

              _data?.country = result;
              return _data?.country!.label;
            },
          ),
          ElevatedButton(
            onPressed: () {
              formKey.currentState?.save();
              widget.onSave?.call(_data!);
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
  void didUpdateWidget(covariant PickerTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(_controller?.text != widget.initialValue) {
      _controller?.dispose();
      _controller = TextEditingController(text: widget.initialValue);
    }
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