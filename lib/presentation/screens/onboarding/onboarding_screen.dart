import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/user_name_provider.dart';
import '../../widgets/branding/expensemate_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  late final AnimationController _blobController;
  int _page = 0;

  List<_PageData> _buildPages(BuildContext context) {
    final l = context.l10n;
    return [
      _PageData(
        icon: Icons.receipt_long_rounded,
        title: l.onboardTrackTitle,
        subtitle: l.onboardTrackSubtitle,
        accents: const [Color(0xFF8B7CE0), Color(0xFF6750A4), Color(0xFF3E2A7A)],
      ),
      _PageData(
        icon: Icons.shopping_cart_rounded,
        title: l.onboardGroceryTitle,
        subtitle: l.onboardGrocerySubtitle,
        accents: const [Color(0xFF7BD3EA), Color(0xFF00A5B5), Color(0xFF00565F)],
      ),
      _PageData(
        icon: Icons.shield_rounded,
        title: l.onboardSecurityTitle,
        subtitle: l.onboardSecuritySubtitle,
        accents: const [Color(0xFF6EE7B7), Color(0xFF059669), Color(0xFF064E3B)],
      ),
      _PageData(
        icon: Icons.savings_rounded,
        title: l.onboardOwnDataTitle,
        subtitle: l.onboardOwnDataSubtitle,
        accents: const [Color(0xFFF6C445), Color(0xFFE68A00), Color(0xFF7A3F00)],
      ),
      _PageData(
        icon: Icons.workspace_premium_rounded,
        title: l.onboardFreeTitle,
        subtitle: l.onboardFreeSubtitle,
        accents: const [Color(0xFFFB7185), Color(0xFFE11D48), Color(0xFF881337)],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _blobController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final name = await _askForName();
    if (!mounted) return;
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(userNameProvider.notifier).setName(name);
    }
    await ref.read(hasOnboardedProvider.notifier).markComplete();
    if (!mounted) return;
    context.go(Routes.dashboard);
  }

  Future<String?> _askForName() async {
    final l = context.l10n;
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.onboardNameTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.onboardNameSubtitle,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              maxLength: 40,
              decoration: InputDecoration(
                hintText: l.onboardNameHint,
                border: const OutlineInputBorder(),
                counterText: '',
              ),
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(l.actionSkip),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(l.actionDone),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(context);
    final page = pages[_page];
    final l = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    page.accents[2],
                    Color.lerp(page.accents[1], Colors.black, 0.4)!,
                    Colors.black,
                  ]
                : [
                    page.accents[0].withOpacity(0.18),
                    page.accents[1].withOpacity(0.10),
                    theme.colorScheme.surface,
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated blob background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _blobController,
                  builder: (context, _) => CustomPaint(
                    painter: _BlobPainter(
                      progress: _blobController.value,
                      colors: page.accents,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Row(children: [
                          const ExpenseMateLogo(size: 32, showShadow: false),
                          const SizedBox(width: 10),
                          Text(
                            'ExpenseMate',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                        ]),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            l.actionSkip,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemCount: pages.length,
                      itemBuilder: (context, i) {
                        return _OnboardingPage(
                          data: pages[i],
                          isDark: isDark,
                          selected: _page == i,
                        );
                      },
                    ),
                  ),
                  _dots(theme, isDark, pages),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        if (_page > 0)
                          OutlinedButton(
                            onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : null,
                              side: BorderSide(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.2)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            child: Text(l.actionBack),
                          ),
                        const Spacer(),
                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            icon: Icon(_page == pages.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded),
                            label: Text(_page == pages.length - 1 ? l.actionGetStarted : l.actionNext),
                            style: FilledButton.styleFrom(
                              backgroundColor: page.accents[1],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              elevation: 8,
                              shadowColor: page.accents[1].withOpacity(0.5),
                            ),
                            onPressed: () {
                              if (_page < pages.length - 1) {
                                _controller.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic);
                              } else {
                                _finish();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dots(ThemeData theme, bool isDark, List<_PageData> pages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (i) {
        final active = _page == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: active ? 28 : 8,
          decoration: BoxDecoration(
            color: active
                ? pages[_page].accents[1]
                : (isDark ? Colors.white24 : Colors.black26),
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? [BoxShadow(color: pages[_page].accents[1].withOpacity(0.6), blurRadius: 12)]
                : null,
          ),
        );
      }),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> accents; // [light, mid, deep]

  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accents,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final bool isDark;
  final bool selected;

  const _OnboardingPage({
    required this.data,
    required this.isDark,
    required this.selected,
  });

  bool get _isSecurity => data.icon == Icons.shield_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isSecurity
              ? _VaultGlyphCard(data: data, isDark: isDark, active: selected)
              : _GlyphCard(data: data, isDark: isDark, active: selected),
          const SizedBox(height: 40),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ) ?? TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
            child: Text(data.title, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlyphCard extends StatelessWidget {
  final _PageData data;
  final bool isDark;
  final bool active;
  const _GlyphCard({required this.data, required this.isDark, required this.active});

  @override
  Widget build(BuildContext context) {
    final base = data.accents[1];
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.9, end: active ? 1.0 : 0.94),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer soft halo
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    base.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Rotating gradient ring
            _RotatingRing(color: base),
            // Depth tile with icon
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: data.accents,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.accents[2].withOpacity(0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 22),
                    spreadRadius: -6,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(isDark ? 0.05 : 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // top shine
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(42),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.white.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      data.icon,
                      size: 68,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: data.accents[2].withOpacity(0.8),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultGlyphCard extends StatelessWidget {
  final _PageData data;
  final bool isDark;
  final bool active;
  const _VaultGlyphCard({required this.data, required this.isDark, required this.active});

  @override
  Widget build(BuildContext context) {
    final base = data.accents[1];
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.9, end: active ? 1.0 : 0.94),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer halo
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [base.withOpacity(0.35), Colors.transparent],
                ),
              ),
            ),
            _RotatingRing(color: base),
            // Vault tile
            Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: data.accents,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.accents[2].withOpacity(0.55),
                    blurRadius: 44,
                    offset: const Offset(0, 22),
                    spreadRadius: -6,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(isDark ? 0.05 : 0.6),
                    blurRadius: 22,
                    offset: const Offset(0, -10),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Top gloss
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(46),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Colors.white.withOpacity(0.45), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content: shield + PIN dots
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 70,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: data.accents[2].withOpacity(0.8),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Fingerprint corner badge (top-right, overlapping the tile)
            Positioned(
              top: 40,
              right: 34,
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0B241C) : Colors.white,
                  border: Border.all(color: base, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: base.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(Icons.fingerprint_rounded, size: 26, color: base),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingRing extends StatefulWidget {
  final Color color;
  const _RotatingRing({required this.color});

  @override
  State<_RotatingRing> createState() => _RotatingRingState();
}

class _RotatingRingState extends State<_RotatingRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Transform.rotate(
        angle: _c.value * math.pi * 2,
        child: CustomPaint(
          size: const Size(190, 190),
          painter: _RingPainter(color: widget.color),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  _RingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0),
          color.withOpacity(0.6),
          color.withOpacity(0),
        ],
        stops: const [0, 0.3, 0.6],
      ).createShader(rect);
    canvas.drawArc(
      rect.deflate(4),
      0,
      math.pi * 1.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.color != color;
}

class _BlobPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final bool isDark;

  _BlobPainter({required this.progress, required this.colors, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    void blob(Offset base, double radius, Color color) {
      final dx = math.sin(t) * 30;
      final dy = math.cos(t * 1.3) * 24;
      final paint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
        ..color = color.withOpacity(isDark ? 0.35 : 0.32);
      canvas.drawCircle(base.translate(dx, dy), radius, paint);
    }

    blob(Offset(size.width * 0.2, size.height * 0.22), 140, colors[0]);
    blob(Offset(size.width * 0.85, size.height * 0.15), 120, colors[1]);
    blob(Offset(size.width * 0.75, size.height * 0.8), 180, colors[2]);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
