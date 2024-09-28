import 'package:flutter/material.dart';

class BackupCodes extends StatelessWidget {
  const BackupCodes({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget messageContaine(String message, String time, bool isRead,
      {bool isOwn = true, bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(
          left: isOwn ? 50 : 10, right: isOwn ? 10 : 50, top: 2, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOwn ? Colors.deepPurple : Colors.grey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isOwn || isLast ? 10 : 0),
          topRight: Radius.circular(isOwn && isLast
              ? 10
              : isOwn
                  ? 0
                  : 10),
          bottomLeft: const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(
            text: message,
            style: TextStyle(color: isOwn ? Colors.white : Colors.black),
          );
          final textPainter = TextPainter(
            text: textSpan,
            maxLines: 1,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(
              maxWidth:
                  constraints.maxWidth - 60); // Adjust for time and icon width

          final isSingleLine = textPainter.didExceedMaxLines == false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSingleLine)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                            color: isOwn ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      time,
                      style: TextStyle(
                          color: isOwn ? Colors.white : Colors.black,
                          fontSize: 10),
                    ),
                    isOwn ? const SizedBox(width: 5) : const SizedBox(width: 0),
                    if (isRead && isOwn)
                      const Icon(
                        Icons.done_all,
                        color: Colors.white,
                        size: 12,
                      ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style:
                          TextStyle(color: isOwn ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                              color: isOwn ? Colors.white : Colors.black,
                              fontSize: 10),
                        ),
                        isOwn
                            ? const SizedBox(width: 5)
                            : const SizedBox(width: 0),
                        if (isRead && isOwn)
                          const Icon(
                            Icons.done_all,
                            color: Colors.white,
                            size: 12,
                          ),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}