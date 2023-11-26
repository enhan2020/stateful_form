import 'package:flutter/material.dart';

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
  final List<Country> countryList = const [
    Country(label: 'Malaysia', code: 'my'),
    Country(label: 'Singapore', code: 'sg'),
    Country(label: 'Indonesia', code: 'id'),
  ];

  Contact? contact;
  UniqueKey _key = UniqueKey();

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
                key: _key,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            contact = Contact(
              name: 'Ferry',
              dob: DateTime(2000, 4, 4),
              country: countryList[1],
            );
            _key = UniqueKey();
          });
        },
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