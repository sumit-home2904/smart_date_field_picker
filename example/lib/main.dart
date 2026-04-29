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
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
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
  List<DateTime?> initDate = List.generate(20, (index) => null);
  final _form = GlobalKey<FormState>();
  List<OverlayPortalController> controller = List.generate(20, (index) => OverlayPortalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _form,
        child: ListView.builder(
          itemCount: 20,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return SmartDateFieldPicker(
              pickerDecoration: PickerDecoration(width: 270),
              initialDate: initDate[index],
              controller: controller[index],
              onDateSelected: (value) {
                setState(() {
                  initDate[index] = value ?? DateTime.now();
                });
              },
            );
          },
        ),
      ),
    );
  }
}
