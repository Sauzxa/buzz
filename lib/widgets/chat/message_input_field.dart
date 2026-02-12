import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/colors.dart';
import '../../l10n/app_localizations.dart';

class MessageInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String, String)? onSendFile; // filePath, fileType
  final bool isSending;

  const MessageInputField({
    super.key,
    required this.onSendMessage,
    this.onSendFile,
    this.isSending = false,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isSending) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  Future<void> _handleImagePicker() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null && widget.onSendFile != null) {
        widget.onSendFile!(image.path, 'IMAGE');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)?.translate('error_picking_image') ?? 'Error picking image'}: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleCameraPicker() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null && widget.onSendFile != null) {
        widget.onSendFile!(photo.path, 'IMAGE');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)?.translate('error_taking_photo') ?? 'Error taking photo'}: $e',
            ),
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('share_content') ??
                  'Share Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library_rounded,
                  color: Colors.purple,
                  label:
                      AppLocalizations.of(
                        context,
                      )?.translate('gallery_option') ??
                      'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _handleImagePicker();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.roseColor,
                  label:
                      AppLocalizations.of(
                        context,
                      )?.translate('camera_option') ??
                      'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _handleCameraPicker();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.article_rounded,
                  color: Colors.orange,
                  label:
                      AppLocalizations.of(
                        context,
                      )?.translate('document_option') ??
                      'Document',
                  onTap: () {
                    // Navigator.pop(context);
                    // Document picker not implemented yet
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: Icon(Icons.attach_file, color: AppColors.roseColor),
              onPressed: widget.isSending ? null : _showAttachmentOptions,
            ),

            // Text input field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)?.translate('chat_hint') ??
                        ' Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  enabled: !widget.isSending,
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: _isComposing && !widget.isSending
                    ? AppColors.roseColor
                    : Theme.of(context).disabledColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: widget.isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, size: 22),
                color: Colors.white,
                onPressed: _isComposing && !widget.isSending
                    ? _handleSubmit
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
