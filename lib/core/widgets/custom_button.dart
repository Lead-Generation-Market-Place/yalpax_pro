import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';

enum CustomButtonType { primary, secondary, outline, text }

enum CustomButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final CustomButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool enabled;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.enabled = true,
    this.margin,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || isLoading || onPressed == null;

    return Container(
      margin: margin,
      width: isFullWidth ? double.infinity : width,
      height: height ?? _getHeight(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: isDisabled ? Colors.transparent : null,
          highlightColor: isDisabled ? Colors.transparent : null,
          child: Ink(
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDisabled),
              borderRadius: BorderRadius.circular(12),
              border: type == CustomButtonType.outline && !isDisabled
                  ? Border.all(color: AppColors.primaryBlue)
                  : type == CustomButtonType.outline && isDisabled
                  ? Border.all(color: AppColors.lighten(Colors.white))
                  : null,
              boxShadow: type != CustomButtonType.text && !isDisabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildContent(isDisabled),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDisabled) {
    if (isLoading) {
      return SizedBox(
        height: _getLoaderSize(),
        width: _getLoaderSize(),
        child: Lottie.asset(
          'assets/lottie/button_loader.json',
          fit: BoxFit.contain,
        ),
      );
    }

    final textStyle = _getTextStyle(isDisabled);
    final iconSize = _getIconSize();

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon!, size: iconSize, color: textStyle.color),
          if (text.isNotEmpty) const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }

    return Text(text, style: textStyle);
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isLoading) {
      return AppColors.primaryBlue;
    }

    if (isDisabled) {
      return type == CustomButtonType.text
          ? Colors.transparent
          : AppColors.neutral200;
    }

    switch (type) {
      case CustomButtonType.primary:
        return AppColors.primaryBlue;
      case CustomButtonType.secondary:
        return AppColors.secondaryBlue;
      case CustomButtonType.outline:
      case CustomButtonType.text:
        return Colors.transparent;
    }
  }


  TextStyle _getTextStyle(bool isDisabled) {
    final baseStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: _getFontSize(),
    );

    if (isDisabled) {
      return baseStyle.copyWith(
        color: type == CustomButtonType.text
            ? AppColors.neutral400
            : AppColors.neutral500,
      );
    }

    switch (type) {
      case CustomButtonType.primary:
      case CustomButtonType.secondary:
        return baseStyle.copyWith(color: Colors.white);
      case CustomButtonType.outline:
      case CustomButtonType.text:
        return baseStyle.copyWith(color: AppColors.primaryBlue);
    }
  }

  double _getHeight() {
    switch (size) {
      case CustomButtonSize.small:
        return 32;
      case CustomButtonSize.medium:
        return 44;
      case CustomButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 12;
      case CustomButtonSize.medium:
        return 14;
      case CustomButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 16;
      case CustomButtonSize.medium:
        return 20;
      case CustomButtonSize.large:
        return 24;
    }
  }

  double _getLoaderSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 24;
      case CustomButtonSize.medium:
        return 36;
      case CustomButtonSize.large:
        return 48;
    }
  }

  static styleFrom({required Color backgroundColor, required Color foregroundColor, required int elevation, required BorderSide side}) {}
}
