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
  final colorPickerProperties = ColorPickerProperties();
  final colorPickerComboProperties = ColorPickerComboProperties();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('ColorPicker sample app')),
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColorPickerDemoItem<ColorPickerProperties>(
                properties: colorPickerProperties,
                childBuilder: (properties, editor) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color Picker',
                        style: TextStyle(color: Colors.grey, fontSize: 20.0)),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 300,
                      height: 400,
                      child: ColorPicker(
                        color: properties.color.value,
                        onColorChanged: (color) =>
                            properties.color.value = color,
                        showColorContainer: properties.showColorContainer.value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 64),
              _ColorPickerDemoItem<ColorPickerComboProperties>(
                properties: colorPickerComboProperties,
                childBuilder: (properties, editor) => SizedBox(
                  width: 300,
                  child: ColorPickerCombo(
                    title: 'Color Picker Combo',
                    color: properties.color.value,
                    onColorChanged: (color) => properties.color.value = color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ColorPickerDemoItem<TProperties extends ColorPickerPropertiesBase>
    extends DemoItemBase<TProperties> {
  const _ColorPickerDemoItem({
    Key key,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  }) : super(key: key, properties: properties, childBuilder: childBuilder);

  @override
  State<StatefulWidget> createState() =>
      _ColorPickerDemoItemState<TProperties>();
}

class _ColorPickerDemoItemState<TProperties extends ColorPickerPropertiesBase>
    extends DemoItemStateBase<TProperties> {
  @override
  Widget buildChild() => widget.properties.apply(child: super.buildChild());

  @override
  Widget buildProperties() {
    final properties = widget.properties;
    final editors = properties.editors;
    return Theme(
      data: ThemeData(
          inputDecorationTheme:
              const InputDecorationTheme(border: OutlineInputBorder())),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: editors.length,
        itemBuilder: (context, index) => editors[index].build(),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}

abstract class ColorPickerPropertiesBase {
  Set<EditorsBuilder> excludes;

  final color = ColorEditor(title: 'Color');
  final showColorContainer =
      BoolEditor(title: 'Show Color Container', value: true);
  final trackHeight = IntEditor(title: 'Track Height', value: 12, minValue: 1);
  final alphaRectSize =
      IntEditor(title: 'Alpha Rect Size', value: 6, minValue: 1);
  final alphaColor =
      ColorEditor(title: 'Alpha Color', value: Color(0xffe0e0e0));
  final paletteCursorSize =
      IntEditor(title: 'Palette Cursor Size', value: 24, minValue: 1);
  final paletteCursorColor =
      ColorEditor(title: 'Palette Cursor Color', value: Colors.white);
  final paletteCursorWidth =
      IntEditor(title: 'Palette Cursor Width', value: 2, minValue: 1);
  final colorContainerHeight =
      IntEditor(title: 'Color Container Height', value: 76, minValue: 1);
  final withAlpha = BoolEditor(title: 'With Alpha', value: true);
  final comboPopupWidth =
      IntEditor(title: 'Combo Popup Width', value: 0, minValue: 0);
  final comboPopupHeight =
      IntEditor(title: 'Combo Popup Height', value: 400, minValue: 0);
  final comboColorContainerHeight =
      IntEditor(title: 'Combo Color Container Height', value: 24, minValue: 0);

  List<EditorsBuilder> get editors => [
        color,
        showColorContainer,
        trackHeight,
        alphaRectSize,
        alphaColor,
        paletteCursorSize,
        paletteCursorColor,
        paletteCursorWidth,
        colorContainerHeight,
        withAlpha,
        comboPopupWidth,
        comboPopupHeight,
        comboColorContainerHeight,
      ].where((e) => excludes?.contains(e) != true).toList();
}

class ColorPickerProperties extends ColorPickerPropertiesBase {
  ColorPickerProperties() {
    excludes = {comboPopupWidth, comboPopupHeight, comboColorContainerHeight};
  }
}

class ColorPickerComboProperties extends ColorPickerPropertiesBase {
  ColorPickerComboProperties() {
    excludes = {showColorContainer};
  }
}

extension ColorPickerPropertiesExtension on ColorPickerPropertiesBase {
  Widget apply({@required Widget child}) {
    return ColorPickerContext(
      parameters: ColorPickerParameters(
        trackHeight: trackHeight.value.toDouble(),
        alphaRectSize: alphaRectSize.value.toDouble(),
        alphaColor: alphaColor.value,
        paletteCursorSize: paletteCursorSize.value.toDouble(),
        paletteCursorColor: paletteCursorColor.value,
        paletteCursorWidth: paletteCursorWidth.value.toDouble(),
        colorContainerHeight: colorContainerHeight.value.toDouble(),
        withAlpha: withAlpha.value,
        comboPopupSize: Size(comboPopupWidth.value.toDouble(),
            comboPopupHeight.value.toDouble()),
        comboColorContainerHeight: comboColorContainerHeight.value.toDouble(),
      ),
      child: child,
    );
  }
}
