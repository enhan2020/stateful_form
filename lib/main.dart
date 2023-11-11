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
  var contact = const Contact(firstName: '', lastName: '');

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
                onSave: (value) => setState(() {
                  contact = value;
                }),
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
  final void Function(Contact)? onSave;

  const CustomForm({super.key, required this.initData, required this.onSave});

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    if (widget.initData != null) {
      _firstName = widget.initData!.firstName;
      _lastName = widget.initData!.lastName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _firstName,
            onSaved: (value) => _firstName = value ?? '',
          ),
          TextFormField(
            initialValue: _lastName,
            onSaved: (value) => _lastName = value ?? '',
          ),
          ElevatedButton(
            onPressed: () {
              formKey.currentState?.save();
              widget.onSave?.call(
                Contact(
                  firstName: _firstName,
                  lastName: _lastName,
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

class Contact {
  final String firstName;
  final String lastName;

  const Contact({required this.firstName, required this.lastName});

  @override
  String toString() {
    return 'firstName: $firstName, lastName: $lastName';
  }
}
