import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;
  final bool isOverlay;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.isOverlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              message!,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );

    if (isOverlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? color;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          LoadingIndicator(
            message: loadingMessage,
            color: color,
            isOverlay: true,
          ),
      ],
    );
  }
}

class PullToRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PullToRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      child: child,
    );
  }
}

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.color,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}