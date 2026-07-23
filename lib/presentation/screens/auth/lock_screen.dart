import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    final state = ref.read(pinLockProvider);
    if (state.biometricEnabled && state.biometricAvailable) {
      final ok = await ref.read(pinLockProvider.notifier).authenticateBiometric();
      if (ok && mounted) context.go(Routes.dashboard);
    }
  }

  Future<void> _submit() async {
    HapticFeedback.selectionClick();
    final ok = await ref.read(pinLockProvider.notifier).verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      context.go(Routes.dashboard);
    } else {
      setState(() {
        _error = true;
        _pin = '';
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _type(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length == 4) _submit();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(pinLockProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(Icons.lock_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(context.l10n.lockEnterPin,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(context.l10n.lockUnlockApp,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? (_error ? theme.colorScheme.error : theme.colorScheme.primary)
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _keypad(theme, state.biometricEnabled && state.biometricAvailable),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keypad(ThemeData theme, bool biometric) {
    Widget key(String label, {VoidCallback? onTap, IconData? icon}) => Expanded(
          child: AspectRatio(
            aspectRatio: 1.4,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Material(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onTap ?? () => _type(label),
                  child: Center(
                    child: icon != null
                        ? Icon(icon)
                        : Text(label, style: theme.textTheme.headlineSmall),
                  ),
                ),
              ),
            ),
          ),
        );
    return Column(
      children: [
        Row(children: [key('1'), key('2'), key('3')]),
        Row(children: [key('4'), key('5'), key('6')]),
        Row(children: [key('7'), key('8'), key('9')]),
        Row(children: [
          if (biometric)
            key('', icon: Icons.fingerprint_rounded, onTap: _tryBiometric)
          else
            const Expanded(child: SizedBox()),
          key('0'),
          key('', icon: Icons.backspace_outlined, onTap: _backspace),
        ]),
      ],
    );
  }
}
