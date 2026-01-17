import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../widgets/pressable_button.dart';
import '../widgets/responsive_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  String? _error;
  bool _showConfetti = false;
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    _businessController.text = auth.businessName;
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _businessController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _error = null);
    final business = _businessController.text.trim();
    if (business.isEmpty) {
      setState(() => _error = 'Please add a business name.');
      return;
    }

    final auth = ref.read(authControllerProvider);
    auth.setBusinessName(business);
    auth.setDisplayName(_displayNameController.text.trim());

    setState(() => _showConfetti = true);
    await _confettiController.forward(from: 0);
    if (!mounted) return;
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
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
                  'A few details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'You can skip your name if you want.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _businessController,
                  decoration: const InputDecoration(
                    labelText: 'Business name',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                PressableButton(
                  onPressed: _finish,
                  child: const Text('Finish'),
                ),
              ],
            ),
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: _ConfettiOverlay(animation: _confettiController),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiOverlay extends StatelessWidget {
  const _ConfettiOverlay({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
    ];
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = Curves.easeOut.transform(animation.value);
        return Stack(
          children: List.generate(10, (index) {
            final random = Random(index);
            final startX = random.nextDouble();
            final drift = (random.nextDouble() - 0.5) * 0.2;
            final size = 6 + random.nextDouble() * 6;
            return Positioned(
              left: MediaQuery.of(context).size.width * (startX + drift * progress),
              top: 20 + progress * 140 + random.nextDouble() * 10,
              child: Opacity(
                opacity: (1 - progress).clamp(0.0, 1.0),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
