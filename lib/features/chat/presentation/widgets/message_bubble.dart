// features/chat/presentation/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/message.dart';
import '../../../../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final bool isLandscape;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLike,
    this.onDislike,
    this.isLandscape = false,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    const englishToPersian = {
      '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
      '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
    };

    String persianTime = '$hour:$minute';
    englishToPersian.forEach((eng, per) {
      persianTime = persianTime.replaceAll(eng, per);
    });

    return persianTime;
  }

  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'متن کپی شد',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  List<TextSpan> _parseText(String text, bool isUser, bool isLandscape) {
    final List<TextSpan> spans = [];

    final TextStyle baseStyle = TextStyle(
      color: isUser ? Colors.white : AppTheme.textPrimaryColor,
      fontSize: isUser ? (isLandscape ? 15 : 14.5) : (isLandscape ? 14.5 : 14),
      fontFamily: 'IRANSansMobile',
      height: 1.8,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
    );

    final TextStyle boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
    );

    final segments = text.split('**');
    bool isBold = false;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];

      if (segment.isNotEmpty) {
        spans.add(TextSpan(
          text: segment,
          style: isBold ? boldStyle : baseStyle,
        ));
      }

      // Toggle bold state for next segment (but not for the last segment if it's unmatched)
      if (i < segments.length - 1) {
        isBold = !isBold;
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = isLandscape
        ? MediaQuery.of(context).size.width * 0.55
        : MediaQuery.of(context).size.width * 0.80;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLandscape ? 20 : 12,
        left: message.isUser ? 0 : 24,
        right: message.isUser ? 24 : 0,
      ),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                gradient: message.isUser ? AppTheme.primaryGradient : null,
                color: message.isUser ? null : AppTheme.aiBubbleColor,
                borderRadius: BorderRadius.circular(isLandscape ? 20 : 18).copyWith(
                  topRight: message.isUser ? const Radius.circular(4) : null,
                  topLeft: !message.isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: message.isUser
                    ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : AppTheme.cardShadow,
                border: message.isUser
                    ? null
                    : Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.all(isLandscape ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: _parseText(message.content, message.isUser, isLandscape),
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : AppTheme.textPrimaryColor,
                        fontSize: message.isUser
                            ? (isLandscape ? 15 : 14.5)
                            : (isLandscape ? 14.5 : 14),
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  // Text(
                  //   message.content,
                  //   style: TextStyle(
                  //     color: message.isUser
                  //         ? Colors.white
                  //         : AppTheme.textPrimaryColor,
                  //     fontSize: message.isUser
                  //         ? (isLandscape ? 15 : 14.5)
                  //         : (isLandscape ? 14.5 : 14),
                  //     height: 1.8,
                  //     fontWeight: FontWeight.w500,
                  //     letterSpacing: -0.2,
                  //   ),
                  //   textDirection: TextDirection.rtl,
                  // ),
                  if (onLike != null || onDislike != null || message.isUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: _buildActionButtons(context),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.done_all,
                    color: AppTheme.textTertiaryColor,
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final bool hasExistingFeedback = message.feedback != null;
    final buttonColor = message.isUser
        ? Colors.white.withOpacity(0.7)
        : AppTheme.textTertiaryColor;

    return [
      // Copy button
      _ActionButton(
        icon: Icons.content_copy_rounded,
        color: buttonColor,
        size: isLandscape ? 16 : 15,
        onPressed: () => _copyToClipboard(context),
      ),
      if (onDislike != null) ...[
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.thumb_down_rounded,
          color: message.feedback == FeedbackType.dislike
              ? AppTheme.errorColor
              : hasExistingFeedback
              ? buttonColor.withOpacity(0.3)
              : buttonColor,
          size: isLandscape ? 16 : 15,
          onPressed: hasExistingFeedback ? null : onDislike,
        ),
      ],
      if (onLike != null) ...[
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.thumb_up_rounded,
          color: message.feedback == FeedbackType.like
              ? AppTheme.accentColor
              : hasExistingFeedback
              ? buttonColor.withOpacity(0.3)
              : buttonColor,
          size: isLandscape ? 16 : 15,
          onPressed: hasExistingFeedback ? null : onLike,
        ),
      ],
    ];
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}
