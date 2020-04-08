import 'package:creo_color_picker/creo_color_picker.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  Color _sourceColor = const Color(0xffff0000);
  Color _rainbowColor = const Color(0xffff0000);
  Color _paletteColor = const Color(0xffff0000);
  double _alpha = 0xff;
  Color get _alphaColor => _paletteColor.withAlpha(_alpha.round());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('ColorPicker sample app')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 100,
                child: ColorHex(
                  color: _alphaColor,
                  onColorChanged: (color) =>
                      setState(() => _sourceColor = color),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                  width: 300,
                  height: 200,
                  child: Palette(
                      baseColor: _rainbowColor,
                      color: _sourceColor,
                      onColorChanged: (color) =>
                          setState(() => _paletteColor = color))),
              const SizedBox(height: 16),
              SizedBox(
                  width: 300,
                  child: RainbowSlider(
                    color: _sourceColor,
                    onColorChanged: (color) =>
                        setState(() => _rainbowColor = color),
                  )),
              SizedBox(
                  width: 300,
                  child: AlphaSlider(
                    alpha: _alpha,
                    onAlphaChanged: (alpha) => setState(() => _alpha = alpha),
                    color: _paletteColor,
                  )),
            ],
          ),
        ),
      );
}
