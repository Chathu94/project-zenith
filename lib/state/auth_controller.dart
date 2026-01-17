import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

enum AuthFlow { signIn, signUp, offline }

class AuthController extends ChangeNotifier {
  AuthController(this._service);

  final AuthService _service;

  bool isLoading = false;
  String? errorMessage;
  String? phone;
  AuthFlow flow = AuthFlow.signIn;
  String businessName = 'My Shop';
  String? displayName;

  void setFlow(AuthFlow nextFlow) {
    flow = nextFlow;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setBusinessName(String value) {
    businessName = value.isEmpty ? 'My Shop' : value;
    notifyListeners();
  }

  void setDisplayName(String value) {
    displayName = value.isEmpty ? null : value;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> sendOtp(String value) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.sendOtp(value);
      phone = value;
      return true;
    } catch (_) {
      errorMessage = 'We could not send the code. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (phone == null) {
      errorMessage = 'Please enter your phone number first.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.verifyOtp(phone!, code);
      if (!success) {
        errorMessage = 'That code did not match. Try again.';
      }
      return success;
    } catch (_) {
      errorMessage = 'We could not verify the code. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref.read(authServiceProvider));
});
