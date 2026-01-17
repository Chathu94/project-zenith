import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../widgets/pressable_button.dart';
import '../widgets/responsive_shell.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );
    _buttonsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'auth-card',
        child: Material(
          type: MaterialType.transparency,
          child: ResponsiveShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(_logoFade),
                    child: _LogoHeader(),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(_textFade),
                    child: Text(
                      'Start selling in seconds.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _buttonsFade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PressableButton(
                        onPressed: () {
                          ref
                              .read(authControllerProvider)
                              .setFlow(AuthFlow.offline);
                          context.goNamed('offline');
                        },
                        child: const Text('Start Offline (Recommended)'),
                      ),
                      const SizedBox(height: 12),
                      PressableButton(
                        onPressed: () {
                          ref
                              .read(authControllerProvider)
                              .setFlow(AuthFlow.signIn);
                          context.goNamed('phone');
                        },
                        variant: PressableButtonVariant.outlined,
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(height: 12),
                      PressableButton(
                        onPressed: () {
                          ref
                              .read(authControllerProvider)
                              .setFlow(AuthFlow.signUp);
                          context.goNamed('phone');
                        },
                        variant: PressableButtonVariant.outlined,
                        child: const Text('Create Account'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Offline works without internet. Enable backup & multi-branch later.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Zenith POS',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
