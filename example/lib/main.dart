import 'package:creo_color_picker/creo_color_picker.dart';
import 'package:demo_items/demo_items.dart';
import 'package:editors/editors.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color Picker',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 20.0)),
                  const SizedBox(height: 16.0),
                  SizedBox(width: 300, height: 400, child: ColorPicker()),
                ],
              ),
              const SizedBox(width: 64),
              SizedBox(
                  width: 300,
                  child: ColorPickerCombo(title: 'Color Picker Combo')),
            ],
          ),
        ),
      );
}

class _ColorPickerDemoItem<TProperties extends ColorPickerProperties>
    extends DemoItemBase<TProperties> {
  _ColorPickerDemoItem(
    Key key,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  ) : super(key: key, properties: properties, childBuilder: childBuilder);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _ColorPickerDemoItemState{
  
}


/*

class _CalendartDemoItem<TProperties extends CalendarProperties>
    extends DemoItemBase<TProperties> {
  const _CalendartDemoItem({
    Key key,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  }) : super(key: key, properties: properties, childBuilder: childBuilder);

  @override
  _CalendartDemoItemState<TProperties> createState() =>
      _CalendartDemoItemState<TProperties>();
}


*/

class ColorPickerProperties {
  final showColorContainer =
      BoolEditor(title: 'Show Color Container', value: true);
}
