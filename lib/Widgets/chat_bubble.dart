import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String timestamp;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMe ? AppColors.roseColor : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(20),
            ),
          ),
          child: Text(
            message,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: isMe ? Colors.white : Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : 20,
            right: isMe ? 20 : 0,
            bottom: 8,
          ),
          child: Text(
            timestamp,
            style: GoogleFonts.dmSans(fontSize: 10, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}
