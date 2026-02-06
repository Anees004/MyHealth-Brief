import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as "Oct 24, 2025"
  String toDisplayDate() {
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format as "Oct 24"
  String toShortDate() {
    return DateFormat('MMM d').format(this);
  }

  /// Format as "October 2025"
  String toMonthYear() {
    return DateFormat('MMMM yyyy').format(this);
  }

  /// Format as "Oct"
  String toMonthShort() {
    return DateFormat('MMM').format(this);
  }

  /// Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Time ago string
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Get initials from name
  String getInitials() {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Check if valid email
  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

/// BuildContext extensions
extension BuildContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get padding
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  /// Show loading dialog
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hide dialog
  void hideDialog() {
    Navigator.of(this).pop();
  }
}

/// Num extensions
extension NumExtensions on num {
  /// Add horizontal spacing
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// Add vertical spacing
  SizedBox get verticalSpace => SizedBox(height: toDouble());
}
