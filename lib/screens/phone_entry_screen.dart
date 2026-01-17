import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import '../widgets/pressable_button.dart';
import '../widgets/responsive_shell.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  CountryOption _selectedCountry = const CountryOption(
    name: 'Sri Lanka',
    dialCode: '+94',
    flag: '🇱🇰',
  );
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<CountryOption>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _CountryPickerSheet(),
    );
    if (selected != null) {
      setState(() => _selectedCountry = selected);
    }
  }

  bool _isValidPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 12;
  }

  Future<void> _sendCode() async {
    setState(() => _error = null);
    final raw = _phoneController.text.trim();
    if (!_isValidPhone(raw)) {
      setState(() => _error = 'Please enter a valid phone number.');
      return;
    }

    final fullPhone = '${_selectedCountry.dialCode} ${raw.replaceAll(RegExp(r'\s+'), '')}';
    final success = await ref.read(authControllerProvider).sendOtp(fullPhone);
    if (!mounted) return;
    if (success) {
      context.goNamed('otp');
    } else {
      setState(() => _error = ref.read(authControllerProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Hero(
        tag: 'auth-card',
        child: Material(
          type: MaterialType.transparency,
          child: ResponsiveShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your phone number',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'We will text you a 6-digit code.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _controller,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _pickCountry,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Text(_selectedCountry.flag),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCountry.dialCode,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.expand_more, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: '77 123 4567',
                            ),
                            onChanged: (_) {
                              if (_error != null) {
                                setState(() => _error = null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
                  onPressed: auth.isLoading ? null : _sendCode,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Code'),
                ),
                const SizedBox(height: 12),
                PressableButton(
                  onPressed: auth.isLoading ? null : () => context.pop(),
                  variant: PressableButtonVariant.outlined,
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CountryOption {
  const CountryOption({
    required this.name,
    required this.dialCode,
    required this.flag,
  });

  final String name;
  final String dialCode;
  final String flag;
}

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet();

  static const List<CountryOption> _countries = [
    CountryOption(name: 'Sri Lanka', dialCode: '+94', flag: '🇱🇰'),
    CountryOption(name: 'India', dialCode: '+91', flag: '🇮🇳'),
    CountryOption(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
    CountryOption(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
    CountryOption(name: 'Singapore', dialCode: '+65', flag: '🇸🇬'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _countries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final country = _countries[index];
        return ListTile(
          leading: Text(country.flag, style: const TextStyle(fontSize: 20)),
          title: Text(country.name),
          subtitle: Text(country.dialCode),
          onTap: () => Navigator.of(context).pop(country),
        );
      },
    );
  }
}
