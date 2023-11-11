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
  Contact? contact = Contact(name: 'John', dob: DateTime(1990, 10, 10));

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
                initData: contact,
                onDatePicker: (date) async {
                  final initialDate = date ?? DateTime.now();
                  return await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: initialDate.subtract(const Duration(days: 30)),
                    lastDate: initialDate.add(const Duration(days: 30)),
                  );
                },
                onSave: (value) => setState(() => contact = value),
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomForm extends StatefulWidget {
  final Contact? initData;
  final Future<DateTime?> Function(DateTime?)? onDatePicker;
  final void Function(Contact)? onSave;

  const CustomForm({
    super.key,
    required this.initData,
    required this.onSave,
    this.onDatePicker,
  });

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final formKey = GlobalKey<FormState>();
  String _name = 'default first';
  DateTime? _dob;
  TextEditingController? _dobController;

  @override
  void initState() {
    super.initState();
    if (widget.initData != null) {
      _name = widget.initData!.name ?? '';
      _dob = widget.initData!.dob;
    }

    _dobController = TextEditingController(text: _dob?.toIso8601String());
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
          TextFormField(
            controller: _dobController,
            readOnly: true,
            onTap: () async {
              final res = await widget.onDatePicker?.call(_dob);
              if (res != null) {
                _dob = res;
                _dobController?.text = _dob!.toIso8601String();
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              formKey.currentState?.save();
              widget.onSave?.call(
                Contact(
                  name: _name,
                  dob: _dob,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dobController?.dispose();
    super.dispose();
  }
}

class Contact {
  final String? name;
  final DateTime? dob;

  const Contact({
    required this.name,
    required this.dob,
  });

  @override
  String toString() {
    return 'name: $name, dob: ${dob?.toIso8601String()}';
  }
}
