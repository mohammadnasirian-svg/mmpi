import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          bgTop: Color(0xFFF5EFE2),
          bgBottom: Color(0xFFE8DEC8),
          cardTop: Color(0xFFFFFDF9),
          cardBottom: Color(0xFFF3ECE0),
          cardBevel: Color(0xFFD0C2A8),
          cardBorder: Color(0xFFE2D6C1),
          textPrimary: Color(0xFF2B2118),
          textSecondary: Color(0xFF6B5B4B),
          accentPrimary: Color(0xFF0D9488),
          accentSecondary: Color(0xFFB45309),
          goldAccent: Color(0xFFD97706),
          isDark: false,
        );
      case 'daylight':
        return const NahiraPalette(
          bgTop: Color(0xFFF1F5F9),
          bgBottom: Color(0xFFE2E8F0),
          cardTop: Color(0xFFFFFFFF),
          cardBottom: Color(0xFFF8FAFC),
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
          bgTop: Color(0xFF000000),
          bgBottom: Color(0xFF090D16),
          cardTop: Color(0xFF151C2C),
          cardBottom: Color(0xFF0D121F),
          cardBevel: Color(0xFF05080F),
          cardBorder: Color(0xFF26334D),
          textPrimary: Color(0xFFF8FAFC),
          textSecondary: Color(0xFF94A3B8),
          accentPrimary: Color(0xFF10B981),
          accentSecondary: Color(0xFF8B5CF6),
          goldAccent: Color(0xFFFBBF24),
          isDark: true,
        );
      case 'royal_3d':
      default:
        return const NahiraPalette(
          bgTop: Color(0xFF0B1120),
          bgBottom: Color(0xFF16213E),
          cardTop: Color(0xFF1E2D4D),
          cardBottom: Color(0xFF141F38),
          cardBevel: Color(0xFF0A1020),
          cardBorder: Color(0xFF334B7C),
          textPrimary: Color(0xFFF8FAFC),
          textSecondary: Color(0xFF94A3B8),
          accentPrimary: Color(0xFF06B6D4),
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
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.topColor,
    this.bottomColor,
    this.bevelColor,
    this.glowColor,
    this.borderRadius = 22,
    this.depth = 6,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cTop = topColor ?? const Color(0xFF1E2D4D);
    final cBot = bottomColor ?? const Color(0xFF141F38);
    final cBev = bevelColor ?? const Color(0xFF090F1E);
    final cGlow = glowColor ?? const Color(0xFF06B6D4);

    Widget cardBody = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: cBev,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: Offset(0, depth + 4),
          ),
          BoxShadow(
            color: cGlow.withOpacity(0.14),
            blurRadius: 20,
            spreadRadius: 1,
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
            color: Colors.white.withOpacity(0.14),
            width: 1.2,
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
    this.height = 66,
    this.borderRadius = 20,
    this.fontSize = 18,
    required this.onTap,
  }) : super(key: key);

  @override
  State<Nahira3DButton> createState() => _Nahira3DButtonState();
}

class _Nahira3DButtonState extends State<Nahira3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double maxDepth = 6.0;
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
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(top: currentOffset),
          decoration: BoxDecoration(
            color: widget.darkBevelColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: currentBevel),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(widget.primaryColor, Colors.white, 0.16)!,
                  widget.primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: widget.fontSize + 6),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (widget.sublabel != null)
                          Text(
                            widget.sublabel!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

class NahiraHeroBanner extends StatelessWidget {
  final VoidCallback? onAboutTap;

  const NahiraHeroBanner({Key? key, this.onAboutTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Nahira3DCard(
      depth: 8,
      tiltX: 0.02,
      borderRadius: 26,
      topColor: const Color(0xFF1A294B),
      bottomColor: const Color(0xFF0E172C),
      bevelColor: const Color(0xFF060B16),
      glowColor: const Color(0xFFF59E0B),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        children: [
          Row(
            children: [
              // 3D Emblem Cube
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF92400E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.amber.shade200, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.psychology_alt_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFF38BDF8)],
                          ).createShader(bounds),
                          child: const Text(
                            "Nahira MMPI",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade400, width: 1),
                          ),
                          child: const Text(
                            "3D ULTRA",
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "سامانه جامع روان‌سنجی و تفسیر بالینی MMPI-2 پیرسون",
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "طراحان و سازندگان:",
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "دکتر محمد نصیریان  •  دکتر نبی تاه کهن",
                        style: TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onAboutTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, color: Colors.white, size: 15),
                        SizedBox(width: 5),
                        Text(
                          "Nasirian.com",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
