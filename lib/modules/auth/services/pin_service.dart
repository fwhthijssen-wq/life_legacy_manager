import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinService {
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }
}
