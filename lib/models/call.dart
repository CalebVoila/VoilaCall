import 'package:flutter/material.dart';

class Call {
  final String phoneNumber;
  final String contactName; // New field for contact name
  final DateTime dateTime;

  Call({
    required this.phoneNumber,
    required this.contactName,
    required this.dateTime,
  });
}
