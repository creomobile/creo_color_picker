library creo_color_picker;

import 'dart:ui';

import 'package:combos/combos.dart';
import 'package:flutter/material.dart';

// * consts

const _mindouble = 0.00001;
const _colorHexDecoration = InputDecoration(
    border: OutlineInputBorder(), labelText: 'Hex', prefix: Text('#'));
const _rainbow = LinearGradient(colors: [
  Color(0xffff0000),
  Color(0xffffff00),
  Color(0xff00ff00),
  Color(0xff00ffff),
  Color(0xff0000ff),
  Color(0xffff00ff),
  Color(0xffff0000),
]);

// * types

typedef ColorPositionChanged<TPosition> = Function(
    TPosition position, Color color);

// * context

class ColorPickerParameters {
  const ColorPickerParameters({
    this.trackHeight,
    this.alphaColor,
  });

  static const defaultParameters = ColorPickerParameters(
    trackHeight: 12.0,
    alphaColor: Color(0xffe0e0e0),
  );

  /// Determine track height for [RainbowSlider] and [AlphaSlider]
  final double trackHeight;

  /// Determine color cells for alpha background in [ColorHex] and [AlphaSlider]
  final Color alphaColor;

  ColorPickerParameters copyWith(double trackHeight, Color alphaColor) =>
      ColorPickerParameters(
        trackHeight: trackHeight ?? this.trackHeight,
        alphaColor: alphaColor ?? this.alphaColor,
      );
}

/// Allows to set [ColorPickerParameters] for all [ColorPicker], [ColorPickerCombo]
/// widgets in the [child].
class ColorPickerContext extends StatelessWidget {
  const ColorPickerContext({
    Key key,
    @required this.parameters,
    @required this.child,
  })  : assert(parameters != null),
        assert(child != null),
        super(key: key);

  final ColorPickerParameters parameters;
  final Widget child;

  static ColorPickerContextData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ColorPickerContextData>();

  @override
  Widget build(BuildContext context) {
    final parentData = ColorPickerContext.of(context);
    final def = parentData == null
        ? ColorPickerParameters.defaultParameters
        : parentData.parameters;
    final my = parameters;
    final merged = ColorPickerParameters(
      trackHeight: my.trackHeight ?? def.trackHeight,
      alphaColor: my.alphaColor ?? def.alphaColor,
    );

    return ColorPickerContextData(this, child, merged);
  }
}

/// Provides [ColorPickerParameters] for the specified [ColorPickerContext].
class ColorPickerContextData extends InheritedWidget {
  const ColorPickerContextData(this._widget, Widget child, this.parameters)
      : super(child: child);

  final ColorPickerContext _widget;
  final ColorPickerParameters parameters;

  @override
  bool updateShouldNotify(ColorPickerContextData oldWidget) =>
      _widget.parameters != oldWidget._widget.parameters;
}

// * ColorPickerCombo

class ColorPickerCombo extends StatefulWidget {
  const ColorPickerCombo({
    Key key,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
    this.withAlpha = true,
    this.colorHexHeight = 76.0,
    this.colorHexDecoration = _colorHexDecoration,
  })  : assert(color != null),
        assert(withAlpha != null),
        assert(colorHexHeight != null),
        super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool withAlpha;
  final double colorHexHeight;
  final InputDecoration colorHexDecoration;

  @override
  _ColorPickerComboState createState() => _ColorPickerComboState();
}

class _ColorPickerComboState extends State<ColorPickerCombo> {
  @override
  Widget build(BuildContext context) => Combo(child: Container());
}

// * ColorPicker

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key key,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
    this.withAlpha = true,
    this.colorHexHeight = 76.0,
    this.colorHexDecoration = _colorHexDecoration,
  })  : assert(color != null),
        assert(withAlpha != null),
        assert(colorHexHeight != null),
        super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool withAlpha;
  final double colorHexHeight;
  final InputDecoration colorHexDecoration;

  @override
  _ColorPickerState createState() => _ColorPickerState(color, withAlpha);
}

class _ColorPickerState extends State<ColorPicker> {
  _ColorPickerState(Color color, bool withAlpha) {
    _updateColor(color, withAlpha);
  }

  Color _color;
  double _rainbowPosition;
  Color _rainbowColor;
  Offset _palettePosition;
  Color _paletteColor;
  double _alpha;

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    var update = false;
    if (widget.withAlpha != oldWidget.withAlpha ||
        widget.colorHexHeight != oldWidget.colorHexHeight ||
        widget.colorHexDecoration != oldWidget.colorHexDecoration) {
      update = true;
    }
    final withAlpha = widget.withAlpha;
    if (withAlpha != oldWidget.withAlpha) {
      if (withAlpha) {
        _alpha = 1.0;
      } else {
        _color = _color.withOpacity(1.0);
      }
    }
    final color = widget.color;
    if (color != oldWidget.color && color != _color) {
      _updateColor(color, widget.withAlpha);
      update = true;
    }
    if (update) setState(() {});
  }

  void _updateColor(Color color, bool withAlpha) {
    _color = color;
    _rainbowPosition = RainbowSlider.getPosition(color);
    _rainbowColor = RainbowSlider.getColor(_rainbowPosition);
    _palettePosition = Palette.getPosition(color);
    _paletteColor = color.withOpacity(1.0);
    _alpha = withAlpha ? color.opacity : 1.0;
  }

  void _updateAlpha() {
    _color =
        widget.withAlpha ? _paletteColor.withOpacity(_alpha) : _paletteColor;
    setState(() {});
    final onColorChanged = widget.onColorChanged;
    if (onColorChanged != null) onColorChanged(_color);
  }

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: widget.colorHexHeight,
          child: ColorHex(
            color: _color,
            onColorChanged: (color) =>
                setState(() => _updateColor(color, widget.withAlpha)),
            withAlpha: widget.withAlpha,
            decoration: widget.colorHexDecoration,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Palette(
            rainbowColor: _rainbowColor,
            position: _palettePosition,
            onPositionChanged: (position, color) {
              _palettePosition = position;
              _paletteColor = color;
              _updateAlpha();
            },
          ),
        ),
        const SizedBox(height: 16),
        RainbowSlider(
          position: _rainbowPosition,
          onPositionChanged: (position, color) {
            _rainbowPosition = position;
            _rainbowColor = color;
            _paletteColor = Palette.getColor(_rainbowColor, _palettePosition);
            _updateAlpha();
          },
        ),
        if (widget.withAlpha)
          AlphaSlider(
            alpha: _alpha,
            color: _paletteColor,
            onAlphaChanged: (alpha) {
              _alpha = alpha;
              _updateAlpha();
            },
          ),
      ]);
}

// * ColorHex

class ColorHex extends StatefulWidget {
  const ColorHex({
    Key key,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
    this.withAlpha = true,
    this.alphaRectSize = 6.0,
    this.decoration = _colorHexDecoration,
  })  : assert(color != null),
        assert(withAlpha != null),
        assert(alphaRectSize != null),
        super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool withAlpha;
  final double alphaRectSize;
  final InputDecoration decoration;

  @override
  _ColorHexState createState() => _ColorHexState(color, withAlpha);
}

class _ColorHexState extends State<ColorHex> {
  _ColorHexState(Color color, bool withAlpha)
      : _color = _getColor(color, withAlpha),
        _controller =
            TextEditingController(text: _getColorHex(color, withAlpha));
  Color _color;
  final TextEditingController _controller;
  String _errorText;

  static Color _getColor(Color color, bool withAlpha) =>
      withAlpha ? color : color.withAlpha(0xff);

  static String _getColorHex(Color color, bool withAlpha) {
    final s = (withAlpha ? color.value : color.value - (color.alpha << 24))
        .toRadixString(16);
    return Iterable.generate((withAlpha ? 8 : 6) - s.length)
            .map((e) => '0')
            .join() +
        s;
  }

  @override
  void initState() {
    super.initState();
    String saveText;

    _controller.addListener(() {
      final text = _controller.text;
      if (text == saveText) return;
      saveText = text;
      final withAlpha = widget.withAlpha;
      if ((text?.length ?? 0) != (withAlpha ? 8 : 6)) {
        _setError(true);
        return;
      }
      final value = int.tryParse(text, radix: 16);
      if (value == null) {
        _setError(true);
        return;
      }
      _setError(false);
      final color = Color(withAlpha ? value : value + 0xff000000);
      if (color != _color) {
        _color = color;
        if (widget.onColorChanged != null) widget.onColorChanged(color);
      }

      _setError(false);
    });
  }

  @override
  void didUpdateWidget(ColorHex oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widget = this.widget;
    final color = widget.color;
    final withAlpha = widget.withAlpha;
    if ((color != oldWidget.color && color != _color) ||
        withAlpha != oldWidget.withAlpha) {
      setState(() => _color = _getColor(color, withAlpha));
      _controller.text = _getColorHex(color, withAlpha);
    }
  }

  void _setError(bool error) {
    final text = error ? '' : null;
    if (text != _errorText) setState(() => _errorText = text);
  }

  @override
  Widget build(BuildContext context) {
    final alphaRectSize = widget.alphaRectSize;
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(alphaRectSize),
          ),
          child: Stack(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: CustomPaint(
                    painter:
                        _AlphaPainter(parameters.alphaColor, alphaRectSize),
                  ),
                );
              }),
              Container(color: _color),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      SizedBox(
          width: 116,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
                controller: _controller,
                decoration: widget.decoration.copyWith(errorText: _errorText)),
          )),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class _AlphaPainter extends CustomPainter {
  _AlphaPainter(this.alphaColor, this.alphaRectSize);
  final Color alphaColor;
  final double alphaRectSize;

  static void paintAlpha(Canvas canvas, Rect rect, Color color, double size,
      [int initial = 0]) {
    final paint = Paint()..color = color;
    for (var i = initial; i * size < rect.width; i++) {
      for (var j = 0; j * size < rect.height; j++) {
        if (i % 2 != j % 2) continue;
        canvas.drawRect(
            Rect.fromLTWH(
                rect.left + i * size, rect.top + j * size, size, size),
            paint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) => paintAlpha(canvas,
      Rect.fromLTWH(0, 0, size.width, size.height), alphaColor, alphaRectSize);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// * Palette

class Palette extends StatefulWidget {
  const Palette({
    Key key,
    this.rainbowColor = const Color(0xffff0000),
    this.position = Offset.zero,
    this.onPositionChanged,
    this.cursorSize = 24.0,
    this.cursorColor = Colors.white,
    this.cursorWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  })  : assert(rainbowColor != null),
        assert(position != null),
        assert(cursorSize != null),
        assert(cursorColor != null),
        assert(cursorWidth != null),
        super(key: key);

  final Color rainbowColor;
  final Offset position;
  final ColorPositionChanged<Offset> onPositionChanged;
  final double cursorSize;
  final Color cursorColor;
  final double cursorWidth;
  final BorderRadius borderRadius;

  static Offset getPosition(Color color) {
    final channels = _getSortedChannels(color);
    final brightness = channels[0].value / 0xff;
    if (brightness == 0) return const Offset(1, 1);
    final y = 1 - brightness;
    final x = channels[2].value / brightness / 0xff;
    return Offset(x, y);
  }

  static Color getColor(Color rainbowColor, Offset position) => Color.lerp(
      Color.lerp(rainbowColor, Colors.white, position.dx),
      Colors.black,
      position.dy);

  @override
  _PaletteState createState() => _PaletteState(position);
}

class _PaletteState extends State<Palette> {
  _PaletteState(this._position);
  Offset _position;
  Color _color;

  @override
  void didUpdateWidget(Palette oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widget = this.widget;
    final rainbowColor = widget.rainbowColor;
    final position = widget.position;
    if (rainbowColor != oldWidget.rainbowColor ||
        (position != oldWidget.position && position != _position)) {
      setState(() {
        _position = position;
        _color = Palette.getColor(rainbowColor, position);
      });
    }
  }

  void _updatePosition(Offset position, double width, double height) {
    final x = ((width - position.dx) / width).clamp(0.0, 1.0);
    final y = (position.dy / height).clamp(0.0, 1.0);
    setState(() {
      _position = Offset(x, y);
      _color = Palette.getColor(widget.rainbowColor, _position);
    });
    final onPositionChanged = widget.onPositionChanged;
    if (onPositionChanged != null) onPositionChanged(_position, _color);
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final cursorSize = widget.cursorSize;
    final half = cursorSize / 2;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      return GestureDetector(
        onPanDown: (details) =>
            _updatePosition(details.localPosition, width, height),
        onPanUpdate: (details) =>
            _updatePosition(details.localPosition, width, height),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: widget.borderRadius),
          child: Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child:
                    CustomPaint(painter: _PalettePainter(widget.rainbowColor)),
              ),
              Positioned(
                left: width * (1 - _position.dx) - half,
                top: (height * _position.dy) - half,
                child: Container(
                  width: cursorSize,
                  height: cursorSize,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(half),
                    border: Border.all(
                        color: widget.cursorColor, width: widget.cursorWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PalettePainter extends CustomPainter {
  _PalettePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            LinearGradient(colors: [Colors.white, color]).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
                colors: [Colors.black, Colors.black.withOpacity(0.0)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter)
            .createShader(rect),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// * RainbowSlider

class RainbowSlider extends StatefulWidget {
  const RainbowSlider({
    Key key,
    this.position = 0.0,
    this.onPositionChanged,
  })  : assert(position != null),
        super(key: key);

  final double position;
  final ColorPositionChanged<double> onPositionChanged;

  // ignore: missing_return
  static double getPosition(Color color) {
    final channels = _getSortedChannels(color);
    final c0 = channels[0].value;
    final c1 = channels[1].value;
    final c2 = channels[2].value;
    if (c0 == c1 && c0 == c2) return 0.0;
    final second = channels[1].key;
    final coef = (c1 - c2) / (c0 - c2);
    switch (channels[0].key) {
      case _ColorChannel.red: // red / purple
        return second == _ColorChannel.blue ? 6 - coef : 0 + coef;
      case _ColorChannel.green: // yellow / green
        return second == _ColorChannel.red ? 2 - coef : 2 + coef;
      case _ColorChannel.blue: // blue / purple
        return second == _ColorChannel.green ? 4 - coef : 4 + coef;
    }
  }

  static Color getColor(double position) {
    final index = position.truncate();
    final colors = _rainbow.colors;
    final color = colors[index];
    final coef = position - index;
    return coef < _mindouble
        ? color
        : Color.lerp(color, colors[index + 1], coef);
  }

  @override
  _RainbowSliderState createState() => _RainbowSliderState(position);
}

class _RainbowSliderState extends State<RainbowSlider> {
  _RainbowSliderState(this._position)
      : _color = RainbowSlider.getColor(_position);
  double _position;
  Color _color;

  @override
  void didUpdateWidget(RainbowSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final position = widget.position;
    if (position != oldWidget.position && position != _position) {
      _updatePosition(position);
    }
  }

  void _updatePosition(double position) => setState(() {
        _position = position;
        _color = RainbowSlider.getColor(position);
      });

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    return SliderTheme(
      data: SliderThemeData(
          trackShape: const _RainbowSliderTrackShape(),
          trackHeight: parameters.trackHeight,
          thumbColor: color,
          overlayColor: color.withOpacity(0.33)),
      child: Slider(
          value: _position,
          max: _rainbow.colors.length - 1.0,
          onChanged: (position) {
            _updatePosition(position);
            final onPositionChanged = widget.onPositionChanged;
            if (onPositionChanged != null) onPositionChanged(_position, _color);
          }),
    );
  }
}

class _RainbowSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const _RainbowSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    if (sliderTheme.trackHeight <= 0) return;
    final rect = getPreferredRect(
        parentBox: parentBox,
        offset: offset,
        sliderTheme: sliderTheme,
        isEnabled: isEnabled,
        isDiscrete: isDiscrete);
    final radius = Radius.circular(rect.height / 2);
    context.canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius),
        Paint()..shader = _rainbow.createShader(rect));
  }
}

// * AlphaSlider

class AlphaSlider extends StatefulWidget {
  const AlphaSlider({
    Key key,
    this.alpha = 1.0,
    this.onAlphaChanged,
    this.color = const Color(0xffff0000),
  })  : assert(alpha != null && alpha >= 0.0 && alpha <= 1.0),
        assert(color != null),
        super(key: key);

  final double alpha;
  final ValueChanged<double> onAlphaChanged;
  final Color color;

  @override
  _AlphaSliderState createState() => _AlphaSliderState(alpha);
}

class _AlphaSliderState extends State<AlphaSlider> {
  _AlphaSliderState(this._alpha);
  double _alpha;

  @override
  void didUpdateWidget(AlphaSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final alpha = widget.alpha;
    if (alpha != oldWidget.alpha && alpha != _alpha) {
      setState(() => _alpha = alpha);
    }
  }


  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;

    return SliderTheme(
      data: SliderThemeData(
          trackShape: _AlphaSliderTrackShape(
              color: color, alphaColor: parameters.alphaColor),
          trackHeight: parameters.trackHeight,
          thumbColor: color,
          overlayColor: color.withOpacity(0.33)),
      child: Slider(
        value: _alpha,
        max: 1.0,
        onChanged: (value) {
          setState(() => _alpha = value);
          final onAlphaChanged = widget.onAlphaChanged;
          if (onAlphaChanged != null) onAlphaChanged(value);
        },
      ),
    );
  }
}

class _AlphaSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const _AlphaSliderTrackShape(
      {@required this.color, @required this.alphaColor});

  final Color color;
  final Color alphaColor;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    if (sliderTheme.trackHeight <= 0) return;
    final rect = getPreferredRect(
        parentBox: parentBox,
        offset: offset,
        sliderTheme: sliderTheme,
        isEnabled: isEnabled,
        isDiscrete: isDiscrete);
    final size = rect.height / 2;
    final paint = Paint()..color = alphaColor;
    final canvas = context.canvas;
    final radius = Radius.circular(size);
    canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(rect.left, rect.top, size, size),
            topLeft: radius),
        paint);
    _AlphaPainter.paintAlpha(
        canvas,
        Rect.fromLTWH(rect.left, rect.top, rect.width - size, rect.height),
        Colors.black12,
        size,
        1);
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius),
        Paint()
          ..shader = LinearGradient(colors: [color.withOpacity(0.0), color])
              .createShader(rect));
  }
}

// * utils

enum _ColorChannel { red, green, blue }

List<MapEntry<_ColorChannel, int>> _getSortedChannels(Color color) => [
      MapEntry(_ColorChannel.red, color.red),
      MapEntry(_ColorChannel.green, color.green),
      MapEntry(_ColorChannel.blue, color.blue),
    ]..sort((a, b) => b.value.compareTo(a.value));
