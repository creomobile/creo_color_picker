library creo_color_picker;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// * consts

const _mindouble = 0.00001;
const double _maxalpha = 0xff;
const _alphaColor = Color(0xffE0E0E0);
const _rainbow = LinearGradient(colors: [
  Color(0xffff0000),
  Color(0xffffff00),
  Color(0xff00ff00),
  Color(0xff00ffff),
  Color(0xff0000ff),
  Color(0xffff00ff),
  Color(0xffff0000),
]);

// * ColorPicker

// * ColorHex

class ColorHex extends StatefulWidget {
  const ColorHex({
    Key key,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
    this.withAlpha = true,
    this.alphaColor = _alphaColor,
    this.alphaRectSize = 6.0,
    this.decoration = const InputDecoration(
        border: OutlineInputBorder(), labelText: 'Hex', prefix: Text('#')),
  })  : assert(color != null),
        assert(withAlpha != null),
        assert(alphaColor != null),
        assert(alphaRectSize != null),
        super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool withAlpha;
  final Color alphaColor;
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
    final widget = this.widget;
    final alphaRectSize = widget.alphaRectSize;
    final alphaColor = widget.alphaColor;
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
                    painter: _AlphaPainter(alphaColor, alphaRectSize),
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
    this.baseColor = const Color(0xffff0000),
    this.color = const Color(0xffff0000),
    this.onColorChanged,
    this.cursorSize = 24.0,
    this.cursorColor = Colors.white,
    this.cursorWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  })  : assert(baseColor != null),
        assert(color != null),
        assert(cursorSize != null),
        assert(cursorColor != null),
        assert(cursorWidth != null),
        super(key: key);

  final Color baseColor;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final double cursorSize;
  final Color cursorColor;
  final double cursorWidth;
  final BorderRadius borderRadius;

  @override
  _PaletteState createState() => _PaletteState(color);
}

class _PaletteState extends State<Palette> {
  _PaletteState(this._color) : _position = _getPosition(_color);
  Color _color;
  Offset _position;

  static Offset _getPosition(Color color) {
    final channels = _getSortedChannels(color);
    final brightness = channels[0].value / 0xff;
    if (brightness == 0) return const Offset(1, 1);
    final y = 1 - brightness;
    final x = channels[2].value / brightness / 0xff;
    return Offset(x, y);
  }

  @override
  void didUpdateWidget(Palette oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widget = this.widget;
    final color = widget.color;
    if (color != oldWidget.color && color != _color) {
      setState(() {
        _color = color;
        _position = _getPosition(color);
      });
    } else if (widget.baseColor != oldWidget.baseColor) {
      setState(() => _updateColor());
      SchedulerBinding.instance.addPostFrameCallback((_) => _raiseChanged());
    }
  }

  void _updatePosition(Offset position, double width, double height) {
    final x = ((width - position.dx) / width).clamp(0.0, 1.0);
    final y = (position.dy / height).clamp(0.0, 1.0);
    setState(() {
      _position = Offset(x, y);
      _updateColor();
    });
    _raiseChanged();
  }

  void _updateColor() => _color = Color.lerp(
      Color.lerp(widget.baseColor, Colors.white, _position.dx),
      Colors.black,
      _position.dy);

  void _raiseChanged() {
    final onColorChanged = widget.onColorChanged;
    if (onColorChanged != null) onColorChanged(_color);
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
                child: CustomPaint(painter: _PalettePainter(widget.baseColor)),
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
    this.trackHeight = 12.0,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
  })  : assert(trackHeight != null),
        assert(color != null),
        super(key: key);

  final double trackHeight;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  _RainbowSliderState createState() => _RainbowSliderState(color);
}

class _RainbowSliderState extends State<RainbowSlider> {
  _RainbowSliderState(Color color) : _position = _getPosition(color);
  double _position;

  // ignore: missing_return
  static double _getPosition(Color color) {
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

  Color get _color {
    final position = _position;
    final index = position.truncate();
    final colors = _rainbow.colors;
    final color = colors[index];
    final coef = position - index;
    return coef < _mindouble
        ? color
        : Color.lerp(color, colors[index + 1], coef);
  }

  @override
  void didUpdateWidget(RainbowSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final color = widget.color;
    if (color != oldWidget.color && color != _color) {
      setState(() => _position = _getPosition(color));
      final onColorChanged = widget.onColorChanged;
      if (onColorChanged != null) {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => onColorChanged(_color));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return SliderTheme(
      data: SliderThemeData(
          trackShape: const _RainbowSliderTrackShape(),
          trackHeight: widget.trackHeight,
          thumbColor: color,
          overlayColor: color.withOpacity(0.33)),
      child: Slider(
          value: _position,
          max: _rainbow.colors.length - 1.0,
          onChanged: (value) {
            setState(() => _position = value);
            final onColorChanged = widget.onColorChanged;
            if (onColorChanged != null) onColorChanged(_color);
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
    this.trackHeight = 12.0,
    this.alpha = _maxalpha,
    this.onAlphaChanged,
    this.color = Colors.grey,
    this.alphaColor = _alphaColor,
  })  : assert(trackHeight != null),
        assert(alpha != null && alpha >= 0 && alpha <= _maxalpha),
        assert(color != null),
        assert(alphaColor != null),
        super(key: key);

  final double trackHeight;
  final double alpha;
  final ValueChanged<double> onAlphaChanged;
  final Color color;
  final Color alphaColor;

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
    final widget = this.widget;
    final color = widget.color;
    return SliderTheme(
      data: SliderThemeData(
          trackShape: _AlphaSliderTrackShape(
              color: color, alphaColor: widget.alphaColor),
          trackHeight: widget.trackHeight,
          thumbColor: color,
          overlayColor: color.withOpacity(0.33)),
      child: Slider(
        value: _alpha,
        max: _maxalpha,
        onChanged: (value) {
          setState(() => _alpha = value);
          if (widget.onAlphaChanged != null) widget.onAlphaChanged(value);
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
