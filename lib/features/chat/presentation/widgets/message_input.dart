import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

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
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    cursorIndent(_controller);
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
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(widget.isLandscape ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          boxShadow: widget.isLandscape
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: widget.isLandscape ? 120 : 100,
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  decoration: InputDecoration(
                    hintText: AppConstants.inputHint,
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.isLandscape ? 28 : 24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.isLandscape ? 24 : 20,
                      vertical: widget.isLandscape ? 16 : 12,
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                  onSubmitted: (_) => _handleSend(),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  style: TextStyle(
                    fontSize: widget.isLandscape ? 16 : 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _isEmpty || !widget.enabled
                  ? Colors.grey.shade400
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(widget.isLandscape ? 12 : 10),
              child: InkWell(
                onTap: _isEmpty || !widget.enabled ? null : _handleSend,
                borderRadius: BorderRadius.circular(widget.isLandscape ? 28 : 24),
                child: Container(
                  width: widget.isLandscape ? 42 : 34,
                  height: widget.isLandscape ? 42 : 34,
                  alignment: Alignment.center,
                  child: Center(
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: widget.isLandscape ? 20 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void cursorIndent(TextEditingController controller) {
    controller.addListener(() {
      if (controller.selection ==
          TextSelection.fromPosition(
            TextPosition(
              offset: controller.text.length - 1,
            ),
          )) {
        controller.selection = TextSelection.fromPosition(TextPosition(
          offset: controller.text.length,
        ));
      }
    });
  }
}