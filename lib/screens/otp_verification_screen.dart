import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../widgets/otp_input.dart';
import '../widgets/pressable_button.dart';
import '../widgets/responsive_shell.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with TickerProviderStateMixin {
  static const int _initialSeconds = 30;
  late Timer _timer;
  int _secondsRemaining = _initialSeconds;
  String _code = '';
  bool _showSuccess = false;

  late final AnimationController _shakeController;
  late final AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendCode() async {
    final phone = ref.read(authControllerProvider).phone;
    if (phone == null) return;
    await ref.read(authControllerProvider).sendOtp(phone);
    if (!mounted) return;
    setState(() => _secondsRemaining = _initialSeconds);
    _timer.cancel();
    _startTimer();
  }

  Future<void> _verifyCode() async {
    if (_code.length < 6) return;
    final success = await ref.read(authControllerProvider).verifyOtp(_code);
    if (!mounted) return;
    if (success) {
      setState(() => _showSuccess = true);
      await _successController.forward();
      if (!mounted) return;
      final flow = ref.read(authControllerProvider).flow;
      if (flow == AuthFlow.signUp) {
        context.goNamed('profile');
      } else {
        context.goNamed('home');
      }
    } else {
      HapticFeedback.mediumImpact();
      await _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final phone = auth.phone ?? 'your phone';
    final canResend = _secondsRemaining == 0 && !auth.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveShell(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter the 6-digit code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a code to $phone',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final progress = _shakeController.value;
                    final offset = sin(progress * pi * 6) * 6;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: OtpInput(
                    onChanged: (value) {
                      setState(() => _code = value);
                      if (auth.errorMessage != null) {
                        ref.read(authControllerProvider).clearError();
                      }
                    },
                    onCompleted: (value) {
                      setState(() => _code = value);
                    },
                  ),
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  _secondsRemaining > 0
                      ? 'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                      : 'You can resend a new code now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (auth.isLoading)
                  const LinearProgressIndicator(minHeight: 4),
                const SizedBox(height: 12),
                PressableButton(
                  onPressed: auth.isLoading ? null : _verifyCode,
                  child: const Text('Verify'),
                ),
                const SizedBox(height: 12),
                PressableButton(
                  onPressed: canResend ? _resendCode : null,
                  variant: PressableButtonVariant.outlined,
                  child: const Text('Resend code'),
                ),
              ],
            ),
            if (_showSuccess)
              Positioned.fill(
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: _successController,
                    child: ScaleTransition(
                      scale: _successController.drive(
                        Tween(begin: 0.7, end: 1),
                      ),
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.9),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 48,
                              color:
                                  Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
