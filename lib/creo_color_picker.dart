library creo_color_picker;

import 'dart:ui';

import 'package:combos/combos.dart';
import 'package:flutter/material.dart';

// * consts

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

/// Signature for combo color picker title decorator builder
typedef ColorPickerTitleDecoratorBuilder = Widget Function(
  BuildContext context,
  ColorPickerParameters colorPickerParameters,
  ComboParameters comboParameters,
  ComboController controller,
  String title,
  Widget child,
);

// * context

/// Common parameters for color picker widgets.
class ColorPickerParameters {
  const ColorPickerParameters({
    this.trackHeight,
    this.alphaRectSize,
    this.alphaColor,
    this.colorHexInputDecoration,
    this.paletteCursorSize,
    this.paletteCursorColor,
    this.paletteCursorWidth,
    this.colorContainerHeight,
    this.withAlpha,
    this.titleDecoratorBuilder,
    this.comboPopupSize,
    this.comboColorContainerHeight,
  });

  static const defaultParameters = ColorPickerParameters(
      trackHeight: 12.0,
      alphaRectSize: 6.0,
      alphaColor: Color(0xffe0e0e0),
      colorHexInputDecoration: InputDecoration(
          border: OutlineInputBorder(), labelText: 'Hex', prefix: Text('#')),
      paletteCursorSize: 24.0,
      paletteCursorColor: Colors.white,
      paletteCursorWidth: 2.0,
      colorContainerHeight: 76.0,
      withAlpha: true,
      titleDecoratorBuilder: buildDefaultTitleDecorator,
      comboPopupSize: Size(0, 400),
      comboColorContainerHeight: 24.0);

  /// Determine track height in [RainbowSlider] and [AlphaSlider]
  final double trackHeight;

  /// Determine size of rectangles for alpha background in [ColorContainer]
  final double alphaRectSize;

  /// Determine color rectangles for alpha background in [ColorContainer] and [AlphaSlider]
  final Color alphaColor;

  /// Determine decoration for the input in [ColorHex]
  final InputDecoration colorHexInputDecoration;

  /// Determine cursor size in [Palette]
  final double paletteCursorSize;

  /// Determine cursor color in [Palette]
  final Color paletteCursorColor;

  /// Determine cursor width in [Palette]
  final double paletteCursorWidth;

  /// Determine cursor height of [ColorContainer] in [ColorPicker]
  final double colorContainerHeight;

  /// Determine possibility of alpha setting for color in [ColorHex] and [ColorPicker]
  final bool withAlpha;

  /// Define combo title decorator builder for color picker combo
  final ColorPickerTitleDecoratorBuilder titleDecoratorBuilder;

  /// Determine popup size in [ColorPickerCombo]
  final Size comboPopupSize;

  /// Determine color container height in [ColorPickerCombo]
  final double comboColorContainerHeight;

  /// Creates a copy of this color picker parameters but with the given fields replaced with
  ColorPickerParameters copyWith(
    double trackHeight,
    double alphaRectSize,
    Color alphaColor,
    InputDecoration colorHexInputDecoration,
    double paletteCursorSize,
    Color paletteCursorColor,
    double paletteCursorWidth,
    double colorContainerHeight,
    bool withAlpha,
    ColorPickerTitleDecoratorBuilder titleDecoratorBuilder,
    Size comboPopupSize,
    double comboColorContainerHeight,
  ) =>
      ColorPickerParameters(
        trackHeight: trackHeight ?? this.trackHeight,
        alphaRectSize: alphaRectSize ?? this.alphaRectSize,
        alphaColor: alphaColor ?? this.alphaColor,
        colorHexInputDecoration:
            colorHexInputDecoration ?? this.colorHexInputDecoration,
        paletteCursorSize: paletteCursorSize ?? this.paletteCursorSize,
        paletteCursorColor: paletteCursorColor ?? this.paletteCursorColor,
        paletteCursorWidth: paletteCursorWidth ?? this.paletteCursorWidth,
        colorContainerHeight: colorContainerHeight ?? this.colorContainerHeight,
        withAlpha: withAlpha ?? this.withAlpha,
        titleDecoratorBuilder:
            titleDecoratorBuilder ?? this.titleDecoratorBuilder,
        comboPopupSize: comboPopupSize ?? this.comboPopupSize,
        comboColorContainerHeight:
            comboColorContainerHeight ?? this.comboColorContainerHeight,
      );

  /// Default builder for [titleDecoratorBuilder]
  static Widget buildDefaultTitleDecorator(
    BuildContext context,
    ColorPickerParameters colorPickerParameters,
    ComboParameters comboParameters,
    ComboController controller,
    String title,
    Widget child,
  ) {
    final theme = Theme.of(context);
    final decoration =
        InputDecoration(labelText: title, border: OutlineInputBorder())
            .applyDefaults(theme.inputDecorationTheme)
            .copyWith(
              enabled: comboParameters.enabled,
            );
    return Stack(
      children: [
        Material(
            borderRadius:
                (decoration.enabledBorder as OutlineInputBorder)?.borderRadius,
            child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: InputDecorator(
                decoration: decoration,
                isFocused: controller.opened,
                isEmpty: false,
                expands: true),
          ),
        ),
      ],
    );
  }
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
      alphaRectSize: my.alphaRectSize ?? def.alphaRectSize,
      alphaColor: my.alphaColor ?? def.alphaColor,
      colorHexInputDecoration:
          my.colorHexInputDecoration ?? def.colorHexInputDecoration,
      paletteCursorSize: my.paletteCursorSize ?? def.paletteCursorSize,
      paletteCursorColor: my.paletteCursorColor ?? def.paletteCursorColor,
      paletteCursorWidth: my.paletteCursorWidth ?? def.paletteCursorWidth,
      colorContainerHeight: my.colorContainerHeight ?? def.colorContainerHeight,
      withAlpha: my.withAlpha ?? def.withAlpha,
      titleDecoratorBuilder:
          my.titleDecoratorBuilder ?? def.titleDecoratorBuilder,
      comboPopupSize: my.comboPopupSize ?? def.comboPopupSize,
      comboColorContainerHeight:
          my.comboColorContainerHeight ?? def.comboColorContainerHeight,
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
    this.title,
    this.openedChanged,
    this.hoveredChanged,
    this.onTap,
  })  : assert(color != null),
        super(key: key);

  final Color color;

  final ValueChanged<Color> onColorChanged;

  /// Combo text title.
  /// See also: [ColorPickerParameters.comboTextTitlePlacement]
  final String title;

  /// Callbacks when the popup is opening or closing
  final ValueChanged<bool> openedChanged;

  /// Callbacks when the mouse pointer enters on or exits from child or popup.
  final ValueChanged<bool> hoveredChanged;

  /// Called when the user taps on [child].
  /// Also can be called by 'long tap' event if [ComboParameters.autoOpen]
  /// is set to [ComboAutoOpen.hovered] and platform is not 'Web'
  final GestureTapCallback onTap;

  @override
  _ColorPickerComboState createState() => _ColorPickerComboState(color);
}

class _ColorPickerComboState extends State<ColorPickerCombo>
    implements ComboController {
  _ColorPickerComboState(this._color);
  Color _color;
  final _comboKey = GlobalKey<ComboState>();

  @override
  void didUpdateWidget(ColorPickerCombo oldWidget) {
    final color = widget.color;
    if (color != oldWidget.color && color != _color) {
      setState(() => _color = color);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get opened => _comboKey.currentState?.opened == true;

  @override
  void open() => _comboKey.currentState?.open();

  @override
  void close() => _comboKey.currentState?.close();

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;

    return ComboContext(
      parameters: ComboParameters(
        requiredSpace: parameters.comboPopupSize.height,
        childDecoratorBuilder: (context, comboParameters, controller, child) =>
            parameters.titleDecoratorBuilder(context, parameters,
                comboParameters, controller, widget.title, child),
      ),
      child: Combo(
        key: _comboKey,
        child: ListTile(
          title: SizedBox(
            height: parameters.comboColorContainerHeight,
            child: ColorContainer(color: _color),
          ),
        ),
        popupBuilder: (context, mirrored) => SizedBox.fromSize(
            size: parameters.comboPopupSize,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPicker(
                color: _color,
                onColorChanged: (color) {
                  setState(() => _color = color);
                  final onColorChanged = widget.onColorChanged;
                  if (onColorChanged != null) onColorChanged(color);
                },
                showColorContainer: false,
              ),
            )),
        openedChanged: widget.openedChanged,
        hoveredChanged: widget.hoveredChanged,
        onTap: widget.onTap,
      ),
    );
  }
}

// * ColorPicker

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key key,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
    this.showColorContainer = true,
  })  : assert(color != null),
        assert(showColorContainer != null),
        super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showColorContainer;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color _color;
  double _rainbowPosition;
  Color _rainbowColor;
  Offset _palettePosition;
  Color _paletteColor;
  double _alpha;

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    final withAlpha = parameters.withAlpha;
    final color = widget.color;
    if (color != oldWidget.color && color != _color) {
      _updateColor(color, withAlpha);
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_color != null) return;
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    final withAlpha = parameters.withAlpha;
    _updateColor(widget.color, withAlpha);
  }

  void _updateColor(Color color, bool withAlpha) {
    _color = color;
    _rainbowPosition = RainbowSlider.getPosition(color);
    _rainbowColor = RainbowSlider.getColor(_rainbowPosition);
    _palettePosition = Palette.getPosition(color);
    _paletteColor = color.withOpacity(1.0);
    _alpha = withAlpha ? color.opacity : 1.0;
  }

  void _updateAlpha(bool withAlpha) {
    _color = withAlpha ? _paletteColor.withOpacity(_alpha) : _paletteColor;
    setState(() {});
    _raiseColorChanged();
  }

  void _raiseColorChanged() {
    final onColorChanged = widget.onColorChanged;
    if (onColorChanged != null) onColorChanged(_color);
  }

  @override
  Widget build(BuildContext context) {
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    final withAlpha = parameters.withAlpha;
    final colorHex = ColorHex(
      color: _color,
      onColorChanged: (color) {
        setState(() => _updateColor(color, withAlpha));
        _raiseColorChanged();
      },
    );
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (widget.showColorContainer)
        SizedBox(
          height: parameters.colorContainerHeight,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: ColorContainer(color: _color)),
            const SizedBox(width: 16),
            SizedBox(
              width: 116,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: colorHex,
              ),
            ),
          ]),
        )
      else
        colorHex,
      const SizedBox(height: 16),
      Expanded(
        child: Palette(
          rainbowColor: _rainbowColor,
          position: _palettePosition,
          onPositionChanged: (position, color) {
            _palettePosition = position;
            _paletteColor = color;
            _updateAlpha(withAlpha);
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
          _updateAlpha(withAlpha);
        },
      ),
      if (withAlpha)
        AlphaSlider(
          alpha: _alpha,
          color: _paletteColor,
          onAlphaChanged: (alpha) {
            _alpha = alpha;
            _updateAlpha(withAlpha);
          },
        ),
    ]);
  }
}

// * ColorHex

class ColorHex extends StatefulWidget {
  const ColorHex({
    Key key,
    this.color = const Color(0xffff0000),
    this.onColorChanged,
  })  : assert(color != null),
        super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  _ColorHexState createState() => _ColorHexState();
}

class _ColorHexState extends State<ColorHex> {
  Color _color;
  TextEditingController _controller;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_color != null) return;
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    final withAlpha = parameters.withAlpha;
    final color = widget.color;
    _color = _getColor(color, withAlpha);
    _controller = TextEditingController(text: _getColorHex(color, withAlpha));

    String saveText;
    _controller.addListener(() {
      final text = _controller.text;
      if (text == saveText) return;
      saveText = text;
      final parameters = ColorPickerContext.of(context)?.parameters ??
          ColorPickerParameters.defaultParameters;
      final withAlpha = parameters.withAlpha;
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
    });
  }

  @override
  void didUpdateWidget(ColorHex oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widget = this.widget;
    final color = widget.color;
    if ((color != oldWidget.color && color != _color)) {
      final parameters = ColorPickerContext.of(context)?.parameters ??
          ColorPickerParameters.defaultParameters;
      final withAlpha = parameters.withAlpha;
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
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    return TextField(
      controller: _controller,
      decoration:
          parameters.colorHexInputDecoration.copyWith(errorText: _errorText),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

// * Color Container

class ColorContainer extends StatelessWidget {
  const ColorContainer({Key key, this.color}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    final alphaRectSize = parameters.alphaRectSize;

    return Container(
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
                painter: _AlphaPainter(parameters.alphaColor, alphaRectSize),
              ),
            );
          }),
          Container(color: color),
        ],
      ),
    );
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
  })  : assert(rainbowColor != null),
        assert(position != null),
        super(key: key);

  final Color rainbowColor;
  final Offset position;
  final ColorPositionChanged<Offset> onPositionChanged;

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
    final parameters = ColorPickerContext.of(context)?.parameters ??
        ColorPickerParameters.defaultParameters;
    final cursorSize = parameters.paletteCursorSize;
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
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(parameters.alphaRectSize)),
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
                        color: parameters.paletteCursorColor,
                        width: parameters.paletteCursorWidth),
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
    return coef < 0.00001 ? color : Color.lerp(color, colors[index + 1], coef);
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
        alphaColor,
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
