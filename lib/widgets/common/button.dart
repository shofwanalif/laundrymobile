import 'package:flutter/material.dart';

enum IconPosition { left, right }

class Button extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double fontSize;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double iconSize;
  final double iconSpacing;
  final IconPosition iconPosition;

  const Button({
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 15,
    this.fontSize = 16,
    this.gradientColors,
    this.icon,
    this.iconSize = 20,
    this.iconSpacing = 8,
    this.iconPosition = IconPosition.left,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff4338CA);
    const secondaryColor = Color(0xff6D28D9);
    const accentColor = Color(0xffffffff);

    final screenWidth = MediaQuery.of(context).size.width;

    final defaultPadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.15,
      vertical: 15,
    );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: gradientColors ?? [primaryColor, secondaryColor],
          ),
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: WidgetStatePropertyAll(0),
            alignment: Alignment.center,
            padding: WidgetStatePropertyAll(padding ?? defaultPadding),
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          onPressed: onPressed,
          child: _buildButtonContent(accentColor),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color accentColor) {
    final textWidget = Text(
      text,
      style: TextStyle(color: accentColor, fontSize: fontSize),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(icon, size: iconSize, color: accentColor);

    final spacing = SizedBox(width: iconSpacing);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, spacing, textWidget]
          : [textWidget, spacing, iconWidget],
    );
  }
}
