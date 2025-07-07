import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Required for Get.overlayContext
import '../constants/app_colors.dart';

class CustomFlutterToast {
  static OverlayEntry? _currentToast;



  static void showToast({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    int? seconds,
    BuildContext? context,
  }) {

    _currentToast?.remove();
    _currentToast = null;

    // Get the context from GetX overlay
    final resolvedContext = context ?? Get.overlayContext;
    if (resolvedContext == null) return;

    final overlay = Overlay.of(resolvedContext);
    if (overlay == null) return;

    Color backgroundColor;
    Color textColor = Colors.white;
    IconData? icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case ToastType.info:
      default:
        backgroundColor = AppColors.primaryBlue;
        icon = Icons.info;
        break;
    }

    _currentToast = OverlayEntry(
      builder: (_) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _ToastAnimation(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    // Use seconds if provided, otherwise use duration
    final toastDuration = seconds != null ? Duration(seconds: seconds) : duration;

    Future.delayed(toastDuration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  static void showSuccessToast(String message, {int? seconds, Duration? duration}) {
    showToast(
      message: message,
      type: ToastType.success,
      seconds: seconds,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showErrorToast(String message, {int? seconds, Duration? duration}) {
    showToast(
      message: message,
      type: ToastType.error,
      seconds: seconds,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showWarningToast(String message, {int? seconds, Duration? duration}) {
    showToast(
      message: message,
      type: ToastType.warning,
      seconds: seconds,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showInfoToast(String message, {int? seconds, Duration? duration}) {
    showToast(
      message: message,
      type: ToastType.info,
      seconds: seconds,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}

enum ToastType { success, error, warning, info }

class _ToastAnimation extends StatefulWidget {
  final Widget child;

  const _ToastAnimation({required this.child});

  @override
  State<_ToastAnimation> createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}
