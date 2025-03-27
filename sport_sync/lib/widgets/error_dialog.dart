import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.buttonText,
    this.onRetry,
    this.showRetryButton = false,
  }) : super(key: key);

  // Static method to show the error dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String? buttonText,
    VoidCallback? onRetry,
    bool showRetryButton = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onRetry: onRetry,
        showRetryButton: showRetryButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        if (showRetryButton && onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text(
              'Retry',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            buttonText ?? 'OK',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Network error dialog
class NetworkErrorDialog extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorDialog({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
      showRetryButton: true,
      onRetry: onRetry,
    );
  }
}

// Authentication error dialog
class AuthErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AuthErrorDialog({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Authentication Error',
      message: message,
      showRetryButton: onRetry != null,
      onRetry: onRetry,
    );
  }
}

// Permission error dialog
class PermissionErrorDialog extends StatelessWidget {
  final String permission;
  final VoidCallback? onGrantPermission;

  const PermissionErrorDialog({
    Key? key,
    required this.permission,
    this.onGrantPermission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Permission Required',
      message: 'Please grant $permission permission to continue.',
      buttonText: 'Grant Permission',
      onRetry: onGrantPermission,
      showRetryButton: onGrantPermission != null,
    );
  }
}

// Generic error handler mixin
mixin ErrorHandler<T extends StatefulWidget> on State<T> {
  void handleError(dynamic error) {
    if (!mounted) return;

    // Check for specific error types and show appropriate dialogs
    if (error.toString().contains('network')) {
      showDialog(
        context: context,
        builder: (_) => NetworkErrorDialog(
          onRetry: () {
            // Implement retry logic
          },
        ),
      );
    } else if (error.toString().contains('permission')) {
      showDialog(
        context: context,
        builder: (_) => PermissionErrorDialog(
          permission: 'required',
          onGrantPermission: () {
            // Implement permission request logic
          },
        ),
      );
    } else if (error.toString().contains('auth')) {
      showDialog(
        context: context,
        builder: (_) => AuthErrorDialog(
          message: error.toString(),
          onRetry: () {
            // Implement auth retry logic
          },
        ),
      );
    } else {
      ErrorDialog.show(
        context,
        message: error.toString(),
      );
    }
  }

  Future<T> handleFutureError<T>(
    Future<T> Function() future, {
    String? errorMessage,
  }) async {
    try {
      return await future();
    } catch (e) {
      handleError(errorMessage ?? e);
      rethrow;
    }
  }
}