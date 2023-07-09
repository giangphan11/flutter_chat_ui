import 'dart:ui' show Color, Brightness;

import 'package:equatable/equatable.dart';

import 'constants.dart';

T? _castOrNull<T>(Object? value) => value is T ? value : null;

class ChatTheme extends Equatable {
  final Object? _backgroundColor;
  final Object? _fontName;

  ChatTheme({
    Color? backgroundColor,
    String? fontName,
  })  : _backgroundColor = backgroundColor ?? Object(),
        _fontName = fontName ?? Object();

  const ChatTheme.defaultTheme(Brightness brightness)
      : _backgroundColor = brightness == Brightness.dark
            ? const Color(0xff000000)
            : const Color(0xffffffff),
        _fontName = defaultFontName;

  Color get backgroundColor {
    assert(
      _backgroundColor is Color,
      'Invalid value for backgroundColor. Expected a Color, but got $_backgroundColor.',
    );

    return _backgroundColor as Color;
  }

  String get fontName {
    assert(
      _fontName is String,
      'Invalid value for fontName. Expected a String, but got $_fontName.',
    );

    return _fontName as String;
  }

  ChatTheme copyWith({
    Color? backgroundColor,
    String? fontName,
    Color? someNewColor,
  }) =>
      ChatTheme(
        backgroundColor:
            backgroundColor ?? _castOrNull<Color>(_backgroundColor),
        fontName: fontName ?? _castOrNull<String>(_fontName),
      );

  ChatTheme merge(ChatTheme? otherTheme) {
    if (otherTheme == null) return this;

    return copyWith(
      backgroundColor: _castOrNull<Color>(otherTheme._backgroundColor),
      fontName: _castOrNull<String>(otherTheme._fontName),
    );
  }

  @override
  List<Object?> get props => [_backgroundColor, _fontName];
}
