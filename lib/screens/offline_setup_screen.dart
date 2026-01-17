import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../widgets/pressable_button.dart';
import '../widgets/responsive_shell.dart';

class OfflineSetupScreen extends ConsumerStatefulWidget {
  const OfflineSetupScreen({super.key});

  @override
  ConsumerState<OfflineSetupScreen> createState() => _OfflineSetupScreenState();
}

class _OfflineSetupScreenState extends ConsumerState<OfflineSetupScreen> {
  final TextEditingController _businessController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _businessController.text = ref.read(authControllerProvider).businessName;
  }

  @override
  void dispose() {
    _businessController.dispose();
    super.dispose();
  }

  void _startSelling() {
    setState(() => _error = null);
    final business = _businessController.text.trim();
    if (business.isEmpty) {
      setState(() => _error = 'Please add a business name.');
      return;
    }
    ref.read(authControllerProvider).setBusinessName(business);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick setup',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You can enable backup & multi-branch later in Settings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
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
              onPressed: _startSelling,
              child: const Text('Start Selling'),
            ),
          ],
        ),
      ),
    );
  }
}
