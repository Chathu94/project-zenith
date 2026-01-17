import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _nodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty && index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
    }

    final code = _controllers.map((controller) => controller.text).join();
    widget.onChanged?.call(code);
    if (code.length == 6 && !_controllers.any((c) => c.text.isEmpty)) {
      widget.onCompleted(code);
    }
  }

  void _handlePaste(String value) {
    final characters = value.replaceAll(RegExp(r'\D'), '').split('');
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < characters.length ? characters[i] : '';
    }
    final filled = _controllers.map((controller) => controller.text).join();
    widget.onChanged?.call(filled);
    if (filled.length == 6 && !_controllers.any((c) => c.text.isEmpty)) {
      widget.onCompleted(filled);
      _nodes.last.unfocus();
    }
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _nodes[index - 1].requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_controllers.length, (index) {
        return SizedBox(
          width: 48,
          child: Focus(
            onKeyEvent: (node, event) => _handleKey(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _nodes[index],
              autofocus: index == 0,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
              onChanged: (value) => _handleChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
