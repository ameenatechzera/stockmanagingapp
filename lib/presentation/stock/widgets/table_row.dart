import 'package:flutter/material.dart';

TableRow buildTableRow(String title, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "$title:",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    ],
  );
}
