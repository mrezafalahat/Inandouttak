import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'formatters.dart';

String buildUniqueKey({
  required String jalaliDate,
  required String description,
  required int amount,
  String? chequeNumber,
}) {
  final raw = [
    normalizeText(jalaliDate),
    amount.toString(),
    chequeNumber == null || chequeNumber.trim().isEmpty
        ? normalizeText(description)
        : normalizeText(chequeNumber),
  ].join('|');

  return sha1.convert(utf8.encode(raw)).toString();
}
