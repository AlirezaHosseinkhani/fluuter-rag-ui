import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/message.dart';

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
    // Format time in Persian/Farsi format
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    // Convert to Persian numerals
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
        const SnackBar(
          content: Text('متن کپی شد'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = isLandscape
        ? MediaQuery.of(context).size.width * 0.5
        : MediaQuery.of(context).size.width * 0.75;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLandscape ? 16 : 8,
        left: message.isUser ? 0 : 16,
        right: message.isUser ? 16 : 0,
      ),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              padding: EdgeInsets.all(isLandscape ? 20 : 16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(isLandscape ? 20 : 16).copyWith(
                  topRight: message.isUser
                      ? const Radius.circular(4)
                      : null,
                  topLeft: !message.isUser
                      ? const Radius.circular(4)
                      : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: isLandscape ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: isLandscape ? 16 : 14,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'IRANSansMobile',
                        ),
                        textDirection: TextDirection.rtl,
                      )
                    ],
                  ),
                  // Show feedback buttons for AI messages and copy button for all messages
                  if (onLike != null || onDislike != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: _buildFeedbackButtons(context),
                        ),
                      ],
                    )
                  else if (message.isUser)
                  // Show only copy button for AI messages when no feedback buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _copyToClipboard(context),
                                icon: Icon(
                                  Icons.copy,
                                  size: isLandscape ? 18 : 16,
                                  color: Colors.grey.shade400,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: isLandscape ? 36 : 32,
                                  minHeight: isLandscape ? 36 : 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: message.isUser ? -0.1 : 0.1,
      end: 0,
    );
  }

  List<Widget> _buildFeedbackButtons(BuildContext context) {
    final bool hasExistingFeedback = message.feedback != null;

    return [
      // Copy button
      IconButton(
        onPressed: () => _copyToClipboard(context),
        icon: Icon(
          Icons.copy,
          size: isLandscape ? 18 : 16,
          color: Colors.grey.shade400,
        ),
        constraints: BoxConstraints(
          minWidth: isLandscape ? 36 : 32,
          minHeight: isLandscape ? 36 : 32,
        ),
      ),
      const SizedBox(width: 1),
      // Dislike button
      IconButton(
        onPressed: hasExistingFeedback || onDislike == null ? null : onDislike,
        icon: Icon(
          Icons.thumb_down,
          size: isLandscape ? 18 : 16,
          color: message.feedback == FeedbackType.dislike
              ? Colors.red
              : hasExistingFeedback
              ? Colors.grey.shade300
              : Colors.grey.shade400,
        ),
        constraints: BoxConstraints(
          minWidth: isLandscape ? 36 : 32,
          minHeight: isLandscape ? 36 : 32,
        ),
      ),
      const SizedBox(width: 1),
      // Like button
      IconButton(
        onPressed: hasExistingFeedback || onLike == null ? null : onLike,
        icon: Icon(
          Icons.thumb_up,
          size: isLandscape ? 18 : 16,
          color: message.feedback == FeedbackType.like
              ? Colors.green
              : hasExistingFeedback
              ? Colors.grey.shade300
              : Colors.grey.shade400,
        ),
        constraints: BoxConstraints(
          minWidth: isLandscape ? 36 : 32,
          minHeight: isLandscape ? 36 : 32,
        ),
      ),
    ];
  }
}