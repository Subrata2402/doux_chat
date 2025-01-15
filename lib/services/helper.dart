import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// String baseUrl = "https://chat-server-ffid.onrender.com";
String baseUrl = "http://192.168.0.102:3250";

void customSnackBar(BuildContext context, String message, String type) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            type == "error"
                ? Icons.error
                : type == "warning"
                    ? Icons.warning_rounded
                    : Icons.check_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(message,
              softWrap: true,
              maxLines: 2,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      ),
      backgroundColor: type == "error"
          ? Colors.red
          : type == "warning"
              ? Colors.orange
              : Colors.green,
      // margin: EdgeInsets.symmetric(horizontal: 16),
      behavior: SnackBarBehavior.fixed,
      // showCloseIcon: true,
      dismissDirection: DismissDirection.horizontal,
      elevation: 5,
      duration: const Duration(seconds: 3),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),
  );
}

String getIstTime(String timestamp) {
  // Parse the UTC timestamp
  DateTime utcDateTime = DateTime.parse(timestamp);

  // Convert to Indian Standard Time (IST)
  DateTime istDateTime = utcDateTime.add(const Duration(hours: 5, minutes: 30));

  // Format only the time in 12-hour format (hh:mm a)
  String istTime = DateFormat('hh:mm a').format(istDateTime);
  return istTime;
}

String getIstDateOrDay(String timestamp) {
  // Parse the UTC timestamp
  DateTime utcDateTime = DateTime.parse(timestamp);

  // Convert to Indian Standard Time (IST)
  DateTime istDateTime = utcDateTime.add(const Duration(hours: 5, minutes: 30));

  // Get the current date
  DateTime currentDate = DateTime.now();

  // Format the date in the following ways:
  // 1. If the date is today, return "Today"
  // 2. If the date is yesterday, return "Yesterday"
  // 3. If the date is within the current week, return the day of the week
  // 4. If the date is within the current year, return the date in the format "dd MMM"
  // 5. If the date is not within the current year, return the date in the format "dd MMM yyyy"
  String istDateOrDay;
  if (istDateTime.day == currentDate.day &&
      istDateTime.month == currentDate.month &&
      istDateTime.year == currentDate.year) {
    istDateOrDay = "Today";
  } else if (istDateTime.day == currentDate.day - 1 &&
      istDateTime.month == currentDate.month &&
      istDateTime.year == currentDate.year) {
    istDateOrDay = "Yesterday";
    // } else if (istDateTime.weekday == currentDate.weekday &&
    //     istDateTime.month == currentDate.month &&
    //     istDateTime.year == currentDate.year) {
    //   istDateOrDay = DateFormat('EEEE').format(istDateTime);
  } else if (istDateTime.year == currentDate.year) {
    istDateOrDay = DateFormat('dd MMMM').format(istDateTime);
  } else {
    istDateOrDay = DateFormat('dd MMM yyyy').format(istDateTime);
  }
  return istDateOrDay;
}
