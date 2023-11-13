import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_form.dart';
import 'model.dart';

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
  final initialInformation = {
    'name': 'John Cris',
    'dob': '2000-10-21',
    'country': 'ID',
    'gender': 'F',
  };

  Map<String, dynamic>? configData;
  Map<String, dynamic> _value = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configString = await rootBundle.loadString('assets/sample.json');
      configData = jsonDecode(configString)?['data'];

      for (var info in initialInformation.entries) {
        final key = info.key;
        final value = info.value;
        // skip if key not found in config
        if (configData?.containsKey(key) != true) continue;
        final config = configData?[key];

        // get input field type
        final fieldType =
            FieldType.values.firstWhere((element) => element.value == config?['type'], orElse: () => FieldType.unknown);

        // parse to object
        switch (fieldType) {
          case FieldType.text:
            _value[key] = value;
          case FieldType.datetime:
            _value[key] = DateTime.tryParse(value);
          case FieldType.dropdown:
            if (config?['list']?.containsKey(value) == true) {
              _value[key] = DropdownModel(code: value, label: config!['list']![value]?['label']);
            }
          case FieldType.unknown:
            _value[key] = value;
        }
      }
      setState(() {});
    });
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
          Text(_value.encodeToString.toString()),
          Expanded(
            child: SingleChildScrollView(
              child: CustomForm(
                config: configData ?? {},
                initialValue: _value,
                onDatePicker: _showDatePicker,
                dateFormatter: _dateFormatter,
                onDropdownPicker: _showDropdownPicker,
                onSave: (value) => setState(() => _value = value),
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

  Future<DropdownModel?> _showDropdownPicker(List<DropdownModel> data, DropdownModel? selected) async {
    return await showModalBottomSheet<DropdownModel>(
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

extension on Map<String, dynamic> {
  Map<String, dynamic> get encodeToString {
    final beautifyValue = map((key, value) {
      String? result;
      if (value is DateTime) result = value.toIso8601String();
      if (value is DropdownModel) result = value.code;

      return MapEntry(key, result ?? value);
    });
    return beautifyValue;
  }
}
