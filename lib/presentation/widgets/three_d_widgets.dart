import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_strings.dart';

class NahiraPalette {
  final Color bgTop;
  final Color bgBottom;
  final Color cardTop;
  final Color cardBottom;
  final Color cardBevel;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color goldAccent;
  final bool isDark;

  const NahiraPalette({
    required this.bgTop,
    required this.bgBottom,
    required this.cardTop,
    required this.cardBottom,
    required this.cardBevel,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.goldAccent,
    required this.isDark,
  });

  static NahiraPalette fromPreset(String preset) {
    switch (preset) {
      case 'sepia_warm':
        return const NahiraPalette(
          bgTop: Color(0xFFF6F1E7),
          bgBottom: Color(0xFFEBE2D0),
          cardTop: Color(0xFFFFFDF9),
          cardBottom: Color(0xFFF5EFE4),
          cardBevel: Color(0xFFD5C8B0),
          cardBorder: Color(0xFFE2D7C3),
          textPrimary: Color(0xFF231B12),
          textSecondary: Color(0xFF695A49),
          accentPrimary: Color(0xFF0F766E),
          accentSecondary: Color(0xFFB45309),
          goldAccent: Color(0xFFD97706),
          isDark: false,
        );
      case 'daylight':
        return const NahiraPalette(
          bgTop: Color(0xFFF8FAFC),
          bgBottom: Color(0xFFEFF6FF),
          cardTop: Color(0xFFFFFFFF),
          cardBottom: Color(0xFFF1F5F9),
          cardBevel: Color(0xFFCBD5E1),
          cardBorder: Color(0xFFE2E8F0),
          textPrimary: Color(0xFF0F172A),
          textSecondary: Color(0xFF475569),
          accentPrimary: Color(0xFF0284C7),
          accentSecondary: Color(0xFF4F46E5),
          goldAccent: Color(0xFFD97706),
          isDark: false,
        );
      case 'amoled_black':
        return const NahiraPalette(
          bgTop: Color(0xFF030712),
          bgBottom: Color(0xFF090D16),
          cardTop: Color(0xFF111827),
          cardBottom: Color(0xFF0B0F19),
          cardBevel: Color(0xFF030509),
          cardBorder: Color(0xFF1F2937),
          textPrimary: Color(0xFFF9FAFB),
          textSecondary: Color(0xFF9CA3AF),
          accentPrimary: Color(0xFF06B6D4),
          accentSecondary: Color(0xFF6366F1),
          goldAccent: Color(0xFFFBBF24),
          isDark: true,
        );
      case 'royal_3d':
      default:
        return const NahiraPalette(
          bgTop: Color(0xFF0A1122),
          bgBottom: Color(0xFF111C35),
          cardTop: Color(0xFF182644),
          cardBottom: Color(0xFF101A30),
          cardBevel: Color(0xFF070C18),
          cardBorder: Color(0xFF2A3F6D),
          textPrimary: Color(0xFFF8FAFC),
          textSecondary: Color(0xFF94A3B8),
          accentPrimary: Color(0xFF0EA5E9),
          accentSecondary: Color(0xFF6366F1),
          goldAccent: Color(0xFFF59E0B),
          isDark: true,
        );
    }
  }
}

class Nahira3DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? topColor;
  final Color? bottomColor;
  final Color? bevelColor;
  final Color? glowColor;
  final double borderRadius;
  final double depth;
  final double tiltX;
  final double tiltY;
  final VoidCallback? onTap;

  const Nahira3DCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.topColor,
    this.bottomColor,
    this.bevelColor,
    this.glowColor,
    this.borderRadius = 20,
    this.depth = 5,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cTop = topColor ?? const Color(0xFF182644);
    final cBot = bottomColor ?? const Color(0xFF101A30);
    final cBev = bevelColor ?? const Color(0xFF070C18);
    final cGlow = glowColor ?? const Color(0xFF0EA5E9);

    Widget cardBody = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: cBev,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 16,
            offset: Offset(0, depth + 2),
          ),
          BoxShadow(
            color: cGlow.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: depth),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: [cTop, cBot],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.11),
            width: 1.0,
          ),
        ),
        child: child,
      ),
    );

    if (tiltX != 0.0 || tiltY != 0.0) {
      cardBody = Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(tiltX)
          ..rotateY(tiltY),
        child: cardBody,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: cardBody,
      );
    }
    return cardBody;
  }
}

class NahiraInteractive3DCard extends StatefulWidget {
  final Widget child;
  final NahiraPalette palette;
  final Color? glowColor;
  final EdgeInsetsGeometry padding;

  const NahiraInteractive3DCard({
    Key? key,
    required this.child,
    required this.palette,
    this.glowColor,
    this.padding = const EdgeInsets.all(18),
  }) : super(key: key);

  @override
  State<NahiraInteractive3DCard> createState() => _NahiraInteractive3DCardState();
}

class _NahiraInteractive3DCardState extends State<NahiraInteractive3DCard> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _tiltY = (_tiltY - details.delta.dx * 0.0025).clamp(-0.08, 0.08);
          _tiltX = (_tiltX + details.delta.dy * 0.0025).clamp(-0.08, 0.08);
        });
      },
      onPanEnd: (_) {
        setState(() {
          _tiltX = 0.0;
          _tiltY = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Nahira3DCard(
          depth: 6,
          tiltX: _tiltX,
          tiltY: _tiltY,
          padding: widget.padding,
          topColor: widget.palette.cardTop,
          bottomColor: widget.palette.cardBottom,
          bevelColor: widget.palette.cardBevel,
          glowColor: widget.glowColor ?? widget.palette.accentPrimary,
          child: widget.child,
        ),
      ),
    );
  }
}

class Nahira3DButton extends StatefulWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final Color primaryColor;
  final Color darkBevelColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final VoidCallback onTap;

  const Nahira3DButton({
    Key? key,
    required this.label,
    this.sublabel,
    this.icon,
    required this.primaryColor,
    required this.darkBevelColor,
    this.height = 60,
    this.borderRadius = 16,
    this.fontSize = 15.5,
    required this.onTap,
  }) : super(key: key);

  @override
  State<Nahira3DButton> createState() => _Nahira3DButtonState();
}

class _Nahira3DButtonState extends State<Nahira3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double maxDepth = 5.0;
    final double currentOffset = _isPressed ? maxDepth - 1.0 : 0.0;
    final double currentBevel = _isPressed ? 1.0 : maxDepth;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: SizedBox(
        height: widget.height + maxDepth,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 65),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(top: currentOffset),
          decoration: BoxDecoration(
            color: widget.darkBevelColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: currentBevel),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(widget.primaryColor, Colors.white, 0.14)!,
                  widget.primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: widget.fontSize + 5),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.sublabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.sublabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NahiraTopBrandHeader extends StatelessWidget {
  final AppStrings strings;
  final NahiraPalette palette;
  final VoidCallback onToggleLanguage;

  const NahiraTopBrandHeader({
    Key? key,
    required this.strings,
    required this.palette,
    required this.onToggleLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Nahira3DCard(
      depth: 5,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      topColor: palette.cardTop,
      bottomColor: palette.cardBottom,
      bevelColor: palette.cardBevel,
      glowColor: palette.accentPrimary,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [palette.accentPrimary, palette.accentSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.accentPrimary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.appTitle,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.appSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Language Switch Pill (FA / EN)
          InkWell(
            onTap: onToggleLanguage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: palette.accentPrimary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.accentPrimary.withOpacity(0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate_rounded, color: palette.accentPrimary, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    strings.isEn ? 'فارسی' : 'EN',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NahiraCreatorsShowcaseCard extends StatelessWidget {
  final AppStrings strings;
  final NahiraPalette palette;

  const NahiraCreatorsShowcaseCard({
    Key? key,
    required this.strings,
    required this.palette,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Nahira3DCard(
      depth: 7,
      borderRadius: 22,
      topColor: const Color(0xFF17223B),
      bottomColor: const Color(0xFF0D1526),
      bevelColor: const Color(0xFF060A12),
      glowColor: const Color(0xFFF59E0B),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.creatorsLabel,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Nahira MMPI Clinical Suite",
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: "https://Nasirian.com"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.isEn
                            ? "Website address Nasirian.com copied to clipboard."
                            : "آدرس وب‌سایت رسمی Nasirian.com کپی شد.",
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFB45309)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded, color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Text(
                        "Nasirian.com",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _creatorBadge(
                  name: strings.drNasirian,
                  role: strings.creatorRole1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _creatorBadge(
                  name: strings.drKohan,
                  role: strings.creatorRole2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _creatorBadge({required String name, required String role}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: Color(0xFFFBBF24), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
