import 'dart:async';

class AuthService {
  Future<void> sendOtp(String phone) async {
    // TODO: Hook up your SMS provider or backend endpoint here.
    await Future.delayed(const Duration(milliseconds: 700));
  }

  Future<bool> verifyOtp(String phone, String code) async {
    // TODO: Replace with server-side verification when ready.
    await Future.delayed(const Duration(milliseconds: 800));
    return code == '123456';
  }
}
