import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Country> countryList = const [
    Country(label: 'Malaysia', code: 'my'),
    Country(label: 'Singapore', code: 'sg'),
    Country(label: 'Indonesia', code: 'id'),
  ];

  Contact? contact;

  @override
  void initState() {
    super.initState();
    contact = Contact(
      name: 'John',
      dob: DateTime(1990, 10, 10),
      country: countryList.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Text(contact.toString()),
          Expanded(
            child: SingleChildScrollView(
              child: CustomForm(
                initialValue: contact,
                onDatePicker: _showDatePicker,
                dateFormatter: _dateFormatter,
                countryList: countryList,
                onCountryPicker: _showCountryPicker,
                onSave: (value) => setState(() => contact = value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _showDatePicker(DateTime? dateTime) async {
    final initialDate = dateTime ?? DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate.subtract(const Duration(days: 30)),
      lastDate: initialDate.add(const Duration(days: 30)),
    );
  }

  String? _dateFormatter(DateTime? dateTime) {
    if (dateTime == null) return null;
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<Country?> _showCountryPicker(List<Country> data, Country? selected) async {
    return await showModalBottomSheet<Country>(
      context: context,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: data //
                  .map(
                    (country) => InkWell(
                      onTap: () => Navigator.of(context).pop(country),
                      child: ListTile(
                        title: Text(country.label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

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
