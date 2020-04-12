import 'package:creo_color_picker/creo_color_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(title: 'Flutter Demo', home: ColorPickerExamplePage());
}

class ColorPickerExamplePage extends StatefulWidget {
  const ColorPickerExamplePage();

  @override
  _ColorPickerExamplePageState createState() => _ColorPickerExamplePageState();
}

class _ColorPickerExamplePageState extends State<ColorPickerExamplePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('ColorPicker sample app')),
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 300, height: 400, child: ColorPicker()),
              const SizedBox(width: 16),
              SizedBox(width: 300, child: ColorPickerCombo(title: 'Color Picker Combo')),
            ],
          ),
        ),
      );
}
