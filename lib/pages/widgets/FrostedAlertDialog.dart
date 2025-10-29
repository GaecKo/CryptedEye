import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;

  const FrostedAlertDialog({
    required this.title,
    required this.content,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleLarge!,
                  child: title,
                ),
                const SizedBox(height: 16),
                content,
                if (actions != null) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Instance method to show this dialog
  Future<T?> show<T>(
      BuildContext context, {
        bool barrierDismissible = true,
        Color barrierColor = const Color(0x42000000),
        Duration transitionDuration = const Duration(milliseconds: 250),
      }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim1, __, ___) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: this, // <-- use the current instance!
          ),
        );
      },
    );
  }
}
