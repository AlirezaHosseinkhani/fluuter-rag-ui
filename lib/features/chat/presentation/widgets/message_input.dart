// features/chat/presentation/widgets/message_input.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;
  final bool isLandscape;

  const MessageInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.isLandscape = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _cursorIndent(_controller);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isEmpty = _controller.text.trim().isEmpty;
    });
  }

  void _handleSend() {
    if (!_isEmpty && widget.enabled) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(widget.isLandscape ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          boxShadow: widget.isLandscape ? AppTheme.elevatedShadow : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: widget.isLandscape ? 140 : 120,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(widget.isLandscape ? 20 : 18),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: _focusNode.hasFocus
                      ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: AppConstants.inputHint,
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(
                      color: AppTheme.textTertiaryColor,
                      fontSize: widget.isLandscape ? 15 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.isLandscape ? 24 : 20,
                      vertical: widget.isLandscape ? 16 : 14,
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                  onSubmitted: (_) => _handleSend(),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  style: TextStyle(
                    fontSize: widget.isLandscape ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                    fontFamily: 'IRANSansMobile',
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final isActive = !_isEmpty && widget.enabled;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isLandscape ? 52 : 48,
      height: widget.isLandscape ? 52 : 48,
      decoration: BoxDecoration(
        gradient: isActive ? AppTheme.primaryGradient : null,
        color: isActive ? null : AppTheme.textTertiaryColor,
        borderRadius: BorderRadius.circular(widget.isLandscape ? 16 : 14),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? _handleSend : null,
          borderRadius: BorderRadius.circular(widget.isLandscape ? 16 : 14),
          child: Center(
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: widget.isLandscape ? 22 : 20,
            ),
          ),
        ),
      ),
    );
  }

  void _cursorIndent(TextEditingController controller) {
    controller.addListener(() {
      if (controller.selection ==
          TextSelection.fromPosition(
            TextPosition(offset: controller.text.length - 1),
          )) {
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });
  }
}
