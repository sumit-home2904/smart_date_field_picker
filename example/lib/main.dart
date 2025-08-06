import 'package:flutter/material.dart';
import 'package:smart_date_field_picker/smart_date_field_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Date FieldPicker Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(color: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime initDate = DateTime.now();
  final _form = GlobalKey<FormState>();
  final dropdownKey = GlobalKey<SmartDateFieldPickerState>();
  OverlayPortalController controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _form,
        child: Column(
          children: [
            SmartDateFieldPicker(
              initialDate: initDate,
              controller: controller,
              onDateSelected: (value) {
                setState(() {
                  initDate = value ?? DateTime.now();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
