import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(const MyApp());
}

final AppThemeNotifier appThemeNotifier = AppThemeNotifier();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appThemeNotifier,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Learning Journey',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appThemeNotifier.themeMode,
          home: const PresentationScreen(),
        );
      },
    );
  }
}

class AppThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class AppTheme {
  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00BFA5), // Teal accent
      brightness: Brightness.dark,
      background: const Color(0xFF212121), // Dark grey BG
      surface: const Color(0xFF303030),    // Lighter dark grey for cards/surfaces
      primary: const Color(0xFFE0E0E0),   // Main text color
      onPrimary: Colors.black,
      secondary: const Color(0xFF00BFA5), // Accent
      onSecondary: Colors.black,          // Text on accent
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF212121),
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme.copyWith(
          headlineMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        )).apply(
      bodyColor: const Color(0xFFE0E0E0),
      displayColor: const Color(0xFFE0E0E0),
    ),
  );

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00BFA5),
      brightness: Brightness.light,
      background: Colors.white,
      surface: const Color(0xFFF5F5F5),
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: const Color(0xFF00BFA5),
      onSecondary: Colors.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme.copyWith(
          headlineMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        )).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
  );
}

class PresentationSettings extends InheritedWidget {
  final double fontScale;

  const PresentationSettings({
    Key? key,
    required this.fontScale,
    required Widget child,
  }) : super(key: key, child: child);

  static PresentationSettings? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PresentationSettings>();
  }

  @override
  bool updateShouldNotify(PresentationSettings oldWidget) {
    return fontScale != oldWidget.fontScale;
  }
}

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen>
    with SingleTickerProviderStateMixin {
  int currentSlide = 0;
  final PageController _pageController = PageController();
  double _fontScale = 1.0;
  bool _isHighlightingEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentSlide = index;
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontScale = (_fontScale + 0.05).clamp(0.8, 1.5);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontScale = (_fontScale - 0.05).clamp(0.8, 1.5);
    });
  }

  void _toggleHighlighting() {
    setState(() {
      _isHighlightingEnabled = !_isHighlightingEnabled;
    });
  }

  void nextSlide() {
    if (currentSlide < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void previousSlide() {
    if (currentSlide > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HighlightingOverlay(
      isEnabled: _isHighlightingEnabled,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              nextSlide();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              previousSlide();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          body: Stack(
            children: [
              const GridPaperBackground(),
              SafeArea(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (currentSlide + 1) / slides.length,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary),
                      minHeight: 3,
                    ),
                    Expanded(
                      child: PresentationSettings(
                        fontScale: _fontScale,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: slides.length,
                          itemBuilder: (context, index) {
                            return AnimatedSlidePage(
                              index: index,
                              controller: _pageController,
                              child: SlideLayout(
                                slide: slides[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Footer Navigation
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            slides[currentSlide]['title'],
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.7),
                                fontSize: 14),
                          ),
                          Row(
                            children: [
                              FilledButton.tonal(
                                onPressed: _toggleHighlighting,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _isHighlightingEnabled
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3)
                                      : null,
                                ),
                                child: const Icon(Icons.brush),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                  onPressed: () => appThemeNotifier.toggleTheme(),
                                  child: Icon(
                                      appThemeNotifier.themeMode == ThemeMode.dark
                                          ? Icons.light_mode_outlined
                                          : Icons.dark_mode_outlined),
                              ),
                              const SizedBox(width: 16),
                              FilledButton.tonal(
                                  onPressed: _decreaseFontSize,
                                  child: const Icon(Icons.text_decrease)),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                  onPressed: _increaseFontSize,
                                  child: const Icon(Icons.text_increase)),
                              const SizedBox(width: 24),
                              FilledButton.tonal(
                                onPressed:
                                    currentSlide > 0 ? previousSlide : null,
                                child: const Icon(Icons.arrow_back),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '${currentSlide + 1} / ${slides.length}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: currentSlide < slides.length - 1
                                    ? nextSlide
                                    : null,
                                child: const Icon(Icons.arrow_forward),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HighlightingOverlay extends StatefulWidget {
  final Widget child;
  final bool isEnabled;
  const HighlightingOverlay(
      {Key? key, required this.child, required this.isEnabled})
      : super(key: key);

  @override
  State<HighlightingOverlay> createState() => _HighlightingOverlayState();
}

class _HighlightingOverlayState extends State<HighlightingOverlay> {
  Offset? _pointerPosition;
  final List<HighlightStroke> _strokes = [];
  HighlightStroke? _currentStroke;
  bool _isDrawing = false;
  Timer? _fadeTimer;

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  void _startStroke(Offset position) {
    if (!widget.isEnabled) return;
    _fadeTimer?.cancel();
    setState(() {
      _isDrawing = true;
      _currentStroke = HighlightStroke(
        points: [position],
        color: const Color(0xFFF3B943).withOpacity(0.6),
        strokeWidth: 20.0,
      );
      _strokes.add(_currentStroke!);
    });
  }

  void _updateStroke(Offset position) {
    if (!widget.isEnabled || !_isDrawing || _currentStroke == null) return;
    setState(() {
      _currentStroke!.points.add(position);
    });
  }

  void _endStroke() {
    if (!widget.isEnabled) return;
    setState(() {
      _isDrawing = false;
      _currentStroke = null;
    });
  }

  void _clearHighlights() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _isDrawing = false;
    });
  }

  @override
  void didUpdateWidget(HighlightingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnabled && !widget.isEnabled) {
      _clearHighlights();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onHover: (event) {
        setState(() {
          _pointerPosition = event.localPosition;
        });
      },
      onExit: (event) {
        setState(() {
          _pointerPosition = null;
        });
      },
      child: Listener(
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.mouse && event.buttons == 1) {
            _startStroke(event.localPosition);
          }
        },
        onPointerMove: (event) {
          if (event.kind == PointerDeviceKind.mouse && event.buttons == 1) {
            _updateStroke(event.localPosition);
          }
        },
        onPointerUp: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            _endStroke();
          }
        },
        onPointerCancel: (event) => _endStroke(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            ..._strokes.map((stroke) => StrokeItem(
                  key: stroke.key,
                  stroke: stroke,
                )),
            if (_pointerPosition != null && widget.isEnabled)
              Positioned(
                left: _pointerPosition!.dx,
                top: _pointerPosition!.dy,
                child: IgnorePointer(
                  child: HighlighterCursor(
                    isDrawing: _isDrawing,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HighlightStroke {
  final List<Offset> points;
  final Key key;
  final Color color;
  final double strokeWidth;

  HighlightStroke({
    required this.points,
    this.color = const Color(0xFFF3B943),
    this.strokeWidth = 20.0,
  }) : key = UniqueKey();
}

class StrokeItem extends StatefulWidget {
  final HighlightStroke stroke;

  const StrokeItem({Key? key, required this.stroke}) : super(key: key);

  @override
  State<StrokeItem> createState() => _StrokeItemState();
}

class _StrokeItemState extends State<StrokeItem> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HighlightPainter(stroke: widget.stroke),
      size: Size.infinite,
    );
  }
}

class HighlightPainter extends CustomPainter {
  final HighlightStroke stroke;
  HighlightPainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    
    for (int i = 1; i < stroke.points.length; i++) {
      if (i == 1) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      } else {
        final p0 = stroke.points[i - 2];
        final p1 = stroke.points[i - 1];
        final p2 = stroke.points[i];
        
        final xc = (p0.dx + p1.dx) / 2;
        final yc = (p0.dy + p1.dy) / 2;
        
        path.quadraticBezierTo(p1.dx, p1.dy, xc, yc);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HighlightPainter oldDelegate) {
    return oldDelegate.stroke != stroke;
  }
}

class HighlighterCursor extends StatelessWidget {
  final bool isDrawing;

  const HighlighterCursor({
    Key? key,
    this.isDrawing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-12.5, -12.5),
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF3B943).withOpacity(isDrawing ? 0.6 : 0.3),
          border: Border.all(
            color: const Color(0xFFF3B943),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class GridPaperBackground extends StatelessWidget {
  const GridPaperBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomPaint(
        painter: GridPainter(context: context),
        child: Container(),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final BuildContext context;
  GridPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final paint = Paint()
      ..color = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum DoodleType { star, squiggle, arrow, zigzag }

class Doodle extends StatelessWidget {
  final DoodleType type;
  final double size;
  const Doodle({Key? key, required this.type, this.size = 100})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DoodlePainter(type: type, context: context),
      ),
    );
  }
}

class DoodlePainter extends CustomPainter {
  final DoodleType type;
  final BuildContext context;
  DoodlePainter({required this.type, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case DoodleType.star:
        paint.color = const Color(0xFFF3B943);
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        for (int i = 0; i < 8; i++) {
          final angle = (pi / 4) * i;
          path.moveTo(centerX, centerY);
          path.relativeLineTo(cos(angle) * centerX, sin(angle) * centerY);
        }
        break;
      case DoodleType.squiggle:
        paint.color = const Color(0xFF58C4A0);
        path.moveTo(size.width * 0.1, size.height * 0.5);
        path.quadraticBezierTo(size.width * 0.3, size.height * 0.1,
            size.width * 0.5, size.height * 0.5);
        path.quadraticBezierTo(size.width * 0.7, size.height * 0.9,
            size.width * 0.9, size.height * 0.5);
        break;
      case DoodleType.arrow:
        paint.color = isDarkMode ? Colors.white : Colors.black;
        path.moveTo(size.width * 0.1, size.height * 0.9);
        path.quadraticBezierTo(size.width * 0.3, size.height * 0.2,
            size.width * 0.9, size.height * 0.1);
        path.moveTo(size.width * 0.7, size.height * 0.05);
        path.lineTo(size.width * 0.9, size.height * 0.1);
        path.lineTo(size.width * 0.85, size.height * 0.3);
        break;
      case DoodleType.zigzag:
        paint.color = const Color(0xFFE86193);
        path.moveTo(size.width * 0.1, size.height * 0.8);
        path.lineTo(size.width * 0.4, size.height * 0.2);
        path.lineTo(size.width * 0.6, size.height * 0.8);
        path.lineTo(size.width * 0.9, size.height * 0.2);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SlideLayout extends StatelessWidget {
  final Map<String, dynamic> slide;
  const SlideLayout({Key? key, required this.slide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontScale = PresentationSettings.of(context)!.fontScale;
    final bool isFirstSlide = slide['title'] == slides[0]['title'];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            border: Border.all(
                color: isDarkMode ? Colors.grey.shade600 : Colors.black,
                width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(8, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF58C4A0))),
                    const SizedBox(width: 8),
                    Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFE86193))),
                    const SizedBox(width: 8),
                    Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFF3B943))),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildContent(context, fontScale),
                      if (isFirstSlide) ...[
                        const Positioned(
                          top: 0,
                          left: 20,
                          child: Doodle(type: DoodleType.star, size: 80),
                        ),
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Doodle(type: DoodleType.squiggle, size: 80),
                        ),
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          child: Doodle(type: DoodleType.arrow, size: 80),
                        ),
                        const Positioned(
                          bottom: 20,
                          right: 20,
                          child: Doodle(type: DoodleType.zigzag, size: 80),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double fontScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedSlideTitle(title: slide['title'], fontScale: fontScale),
        if (slide['subtitle'] != null && slide['subtitle'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: Text(
              slide['subtitle'],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.7),
                    fontSize: 26 * fontScale,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        if (slide['subtitle'] != null && slide['subtitle'].isNotEmpty)
          const Divider(height: 32),
        Expanded(child: slide['widget']),
      ],
    );
  }
}

class AnimatedSlideTitle extends StatefulWidget {
  final String title;
  final double fontScale;

  const AnimatedSlideTitle(
      {Key? key, required this.title, required this.fontScale})
      : super(key: key);

  @override
  _AnimatedSlideTitleState createState() => _AnimatedSlideTitleState();
}

class _AnimatedSlideTitleState extends State<AnimatedSlideTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _animation = Tween<Offset>(
      begin: const Offset(0.0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedSlideTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _animation,
        child: Container(
          color: const Color(0xFF00BFA5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 38 * widget.fontScale,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatefulWidget {
  final String text;
  final IconData icon;
  const BulletPoint(this.text,
      {super.key, this.icon = Icons.check_circle_outline});

  @override
  State<BulletPoint> createState() => _BulletPointState();
}

class _BulletPointState extends State<BulletPoint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = PresentationSettings.of(context)!.fontScale;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 12.0),
            child: ScaleTransition(
              scale: _animation,
              child: Icon(widget.icon,
                  size: 22.0 * fontScale,
                  color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          Expanded(
              child: Text(widget.text,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(height: 1.5, fontSize: 20 * fontScale))),
        ],
      ),
    );
  }
}

// TwoColumnLayout for side-by-side content
class TwoColumnLayout extends StatelessWidget {
  final Widget left;
  final Widget right;
  const TwoColumnLayout({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 24),
        Expanded(child: right),
      ],
    );
  }
}

// Custom Animated Widgets
class AnimatedFlutterLogo extends StatefulWidget {
  const AnimatedFlutterLogo({super.key});

  @override
  _AnimatedFlutterLogoState createState() => _AnimatedFlutterLogoState();
}

class _AnimatedFlutterLogoState extends State<AnimatedFlutterLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: 0.5 + (_controller.value * 0.5),
            child: FlutterLogo(
              size: 250,
              style: FlutterLogoStyle.horizontal,
              textColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}

class AnimatedCodeBrackets extends StatefulWidget {
  const AnimatedCodeBrackets({super.key});
  @override
  _AnimatedCodeBracketsState createState() => _AnimatedCodeBracketsState();
}

class _AnimatedCodeBracketsState extends State<AnimatedCodeBrackets>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final iconColor =
              Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.2);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(_animation.value, 0),
                child: Icon(Icons.code_off, size: 150, color: iconColor),
              ),
              const SizedBox(width: 40),
              Transform.translate(
                offset: Offset(-_animation.value, 0),
                child: Icon(Icons.code, size: 150, color: iconColor),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PlatformIconsAnimation extends StatefulWidget {
  const PlatformIconsAnimation({super.key});

  @override
  _PlatformIconsAnimationState createState() => _PlatformIconsAnimationState();
}

class _PlatformIconsAnimationState extends State<PlatformIconsAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final icons = [
    Icons.phone_android,
    Icons.phone_iphone,
    Icons.web,
    Icons.desktop_windows
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      icons.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _staggeredAnimation();
  }

  void _staggeredAnimation() async {
    for (var i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _controllers[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 2000));
    for (var i = 0; i < _controllers.length; i++) {
      if (mounted) _controllers[i].reverse();
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _staggeredAnimation();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          return FadeTransition(
            opacity: _controllers[index],
            child: ScaleTransition(
              scale: _controllers[index],
              child: Icon(icons[index], size: 80, color: iconColor),
            ),
          );
        }),
      ),
    );
  }
}

class InteractiveCounterWidget extends StatefulWidget {
  const InteractiveCounterWidget({super.key});
  @override
  State<InteractiveCounterWidget> createState() =>
      _InteractiveCounterWidgetState();
}

class _InteractiveCounterWidgetState extends State<InteractiveCounterWidget> {
  int _counter = 0;
  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    final fontScale = PresentationSettings.of(context)!.fontScale;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'You have pushed the button this many times:',
          style: TextStyle(fontSize: 20 * fontScale),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '$_counter',
          style:
              TextStyle(fontSize: 48 * fontScale, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(
                fontSize: 18 * fontScale, fontWeight: FontWeight.w600),
          ),
          onPressed: _incrementCounter,
          icon: const Icon(Icons.add),
          label: const Text('Increment'),
        ),
      ],
    );
  }
}

class WidgetTreeVisualizer extends StatefulWidget {
  const WidgetTreeVisualizer({super.key});

  @override
  _WidgetTreeVisualizerState createState() => _WidgetTreeVisualizerState();
}

class _WidgetTreeVisualizerState extends State<WidgetTreeVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WidgetTreePainter(_controller.value, context),
            );
          },
        ),
      ),
    );
  }
}

class WidgetTreePainter extends CustomPainter {
  final double progress;
  final BuildContext context;
  WidgetTreePainter(this.progress, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final linePaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.3)
      ..strokeWidth = 2.0;

    final boxPaint = Paint()
      ..color = secondaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: primaryColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final nodePositions = {
      'root': Offset(size.width / 2, size.height * 0.1),
      'scaffold': Offset(size.width / 2, size.height * 0.35),
      'appBar': Offset(size.width * 0.25, size.height * 0.6),
      'body': Offset(size.width * 0.75, size.height * 0.6),
      'title': Offset(size.width * 0.25, size.height * 0.85),
      'center': Offset(size.width * 0.75, size.height * 0.85),
    };

    final nodeTexts = {
      'root': 'MaterialApp',
      'scaffold': 'Scaffold',
      'appBar': 'AppBar',
      'body': 'Center',
      'title': 'Text',
      'center': 'Text',
    };

    final connections = [
      ['root', 'scaffold'],
      ['scaffold', 'appBar'],
      ['scaffold', 'body'],
      ['appBar', 'title'],
      ['body', 'center'],
    ];

    // Animate drawing lines
    for (int i = 0; i < connections.length; i++) {
      if (progress > (i * 0.15)) {
        final startNode = nodePositions[connections[i][0]]!;
        final endNode = nodePositions[connections[i][1]]!;
        final lineProgress = ((progress - (i * 0.15)) / 0.2).clamp(0.0, 1.0);
        canvas.drawLine(startNode,
            Offset.lerp(startNode, endNode, lineProgress)!, linePaint);
      }
    }

    // Animate drawing boxes and text
    nodePositions.forEach((key, pos) {
      final int index = nodePositions.keys.toList().indexOf(key);
      if (progress > (index * 0.1) + 0.1) {
        final boxProgress =
            ((progress - ((index * 0.1) + 0.1)) / 0.2).clamp(0.0, 1.0);
        final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: pos,
                width: 120 * boxProgress,
                height: 50 * boxProgress),
            const Radius.circular(8));

        canvas.drawRRect(rect, boxPaint);
        canvas.drawRRect(rect, borderPaint);

        if (boxProgress > 0.8) {
          final textPainter = TextPainter(
            text: TextSpan(text: nodeTexts[key], style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(canvas,
              pos - Offset(textPainter.width / 2, textPainter.height / 2));
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant WidgetTreePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const AnimatedListItem({Key? key, required this.index, required this.child})
      : super(key: key);

  @override
  _AnimatedListItemState createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger the animation based on the item's index
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _animation,
        child: widget.child,
      ),
    );
  }
}

class AnimatedCodeBlock extends StatefulWidget {
  final String code;
  const AnimatedCodeBlock(this.code, {super.key});

  @override
  State<AnimatedCodeBlock> createState() => _AnimatedCodeBlockState();
}

class _AnimatedCodeBlockState extends State<AnimatedCodeBlock> {
  bool _animationFinished = false;

  TextStyle _getTextStyle(BuildContext context, double fontScale) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.firaCode(
      color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF282C34),
      fontSize: 16 * fontScale,
      height: 1.6,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = PresentationSettings.of(context)!.fontScale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final codeStyle = _getTextStyle(context, fontScale);
    final trimmedCode = widget.code.trim();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
            width: 0.5),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.0,
            child: SelectableText(trimmedCode, style: codeStyle),
          ),
          if (!_animationFinished)
            AnimatedTextKit(
              isRepeatingAnimation: false,
              onFinished: () {
                if (mounted) {
                  setState(() {
                    _animationFinished = true;
                  });
                }
              },
              animatedTexts: [
                TyperAnimatedText(
                  trimmedCode,
                  speed: const Duration(milliseconds: 30),
                  textStyle: codeStyle,
                ),
              ],
            ),
          if (_animationFinished)
            SelectableText(
              trimmedCode,
              style: codeStyle,
            ),
        ],
      ),
    );
  }
}

class InstallationStepsAnimation extends StatefulWidget {
  const InstallationStepsAnimation({super.key});

  @override
  _InstallationStepsAnimationState createState() =>
      _InstallationStepsAnimationState();
}

class _InstallationStepsAnimationState
    extends State<InstallationStepsAnimation> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedListItem(
            index: 0,
            child: InstallationStep(
                icon: Icons.cloud_download_outlined,
                title: "1. Install Flutter SDK",
                subtitle: "Download from the official website.")),
        AnimatedListItem(
            index: 1,
            child: InstallationStep(
                icon: Icons.code,
                title: "2. Set up an Editor",
                subtitle: "VS Code or Android Studio are recommended.")),
        AnimatedListItem(
            index: 2,
            child: InstallationStep(
                icon: Icons.extension_outlined,
                title: "3. Install Plugins",
                subtitle: "Add Flutter & Dart support to your editor.")),
        AnimatedListItem(
            index: 3,
            child: InstallationStep(
                icon: Icons.health_and_safety_outlined,
                title: "4. Run `flutter doctor`",
                subtitle: "A command to check if your setup is ready!")),
      ],
    );
  }
}

class InstallationStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const InstallationStep(
      {Key? key,
      required this.icon,
      required this.title,
      required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2))),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FrameworkComparisonGraph extends StatefulWidget {
  const FrameworkComparisonGraph({super.key});

  @override
  State<FrameworkComparisonGraph> createState() =>
      _FrameworkComparisonGraphState();
}

class _FrameworkComparisonGraphState extends State<FrameworkComparisonGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter:
              GraphPainter(animationValue: _controller.value, context: context),
        );
      },
    );
  }
}

class GraphPainter extends CustomPainter {
  final double animationValue;
  final BuildContext context;
  GraphPainter({required this.animationValue, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final frameworks = [
      {'name': 'React Native', 'value': 75.0, 'color': Colors.lightBlue},
      {'name': 'KMM', 'value': 40.0, 'color': Colors.purple},
      {'name': 'Flutter', 'value': 90.0, 'color': Colors.cyan},
    ];

    final linePaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Draw axis lines
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), linePaint);

    double barSpacing = 40.0;
    double barWidth = (size.width - (barSpacing * (frameworks.length + 1))) /
        frameworks.length;
    double maxVal = 100.0;

    for (int i = 0; i < frameworks.length; i++) {
      final framework = frameworks[i];
      final barHeight = (framework['value'] as double) /
          maxVal *
          size.height *
          animationValue;
      final barPaint = Paint()..color = (framework['color'] as Color);

      final left = barSpacing + i * (barWidth + barSpacing);
      final top = size.height - barHeight;
      final rect = Rect.fromLTWH(left, top, barWidth, barHeight);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)), barPaint);

      // Draw framework name
      final textPainter = TextPainter(
        text: TextSpan(
          text: framework['name'] as String,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
          canvas,
          Offset(
              left + barWidth / 2 - textPainter.width / 2, size.height + 10));

      // Draw value on top
      if (animationValue > 0.8) {
        final valueTextPainter = TextPainter(
          text: TextSpan(
            text: (framework['value'] as double).toInt().toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final valueOpacity = ((animationValue - 0.8) / 0.2).clamp(0.0, 1.0);
        final valuePaint = Paint()
          ..color = (isDarkMode ? Colors.black : Colors.white)
              .withOpacity(valueOpacity);

        if (barHeight > 30) {
          valueTextPainter.paint(
              canvas,
              Offset(
                  left + barWidth / 2 - valueTextPainter.width / 2, top + 10));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class QuizSlide extends StatefulWidget {
  final List<Map<String, String>> questions;

  const QuizSlide({Key? key, required this.questions}) : super(key: key);

  @override
  _QuizSlideState createState() => _QuizSlideState();
}

class _QuizSlideState extends State<QuizSlide> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: widget.questions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final q = widget.questions[index];
        return QuizCard(
          question: q['question']!,
          hint: q['hint']!,
          answer: q['answer']!,
          index: index,
        );
      },
    );
  }
}

class QuizCard extends StatefulWidget {
  final String question;
  final String hint;
  final String answer;
  final int index;

  const QuizCard(
      {Key? key,
      required this.question,
      required this.hint,
      required this.answer,
      required this.index})
      : super(key: key);

  @override
  _QuizCardState createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool _isAnswerVisible = false;

  @override
  Widget build(BuildContext context) {
    final fontScale = PresentationSettings.of(context)!.fontScale;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _isAnswerVisible = !_isAnswerVisible),
        child: AnimatedListItem(
          index: widget.index,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.question,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * fontScale,
                  ),
                ),
                const Divider(height: 24, thickness: 0.5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: _isAnswerVisible
                      ? Text(
                          widget.answer,
                          key: const ValueKey('answer'),
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Row(
                          key: const ValueKey('hint'),
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18 * fontScale,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.hint,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
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
    );
  }
}

class AnimatedSlidePage extends StatefulWidget {
  final Widget child;
  final int index;
  final PageController controller;

  const AnimatedSlidePage({
    Key? key,
    required this.child,
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  State<AnimatedSlidePage> createState() => _AnimatedSlidePageState();
}

class _AnimatedSlidePageState extends State<AnimatedSlidePage> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - _animation.value) * -0.8),
          alignment: Alignment.center,
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

final List<Map<String, dynamic>> slides = [
  // Module 1
  {
    'title': 'Welcome to Flutter!',
    'subtitle': 'A Journey into Cross-Platform Development',
    'widget': const AnimatedFlutterLogo(),
  },
  {
    'title': 'Module 1: What is Flutter?',
    'subtitle': 'And why is it so popular?',
    'widget': const TwoColumnLayout(
      left: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedListItem(
            index: 0,
            child: BulletPoint(
                "A UI toolkit from Google to build beautiful apps for any screen."),
          ),
          SizedBox(height: 16),
          AnimatedListItem(
            index: 1,
            child: BulletPoint(
                "Write code once in Dart, compile to native for mobile, web & desktop."),
          ),
          SizedBox(height: 16),
          AnimatedListItem(
            index: 2,
            child: BulletPoint(
                "Known for high performance and a rich widget library."),
          ),
        ],
      ),
      right: FrameworkComparisonGraph(),
    ),
  },
  {
    'title': 'Setup & Installation',
    'subtitle': 'Getting your machine ready for Flutter',
    'widget': const InstallationStepsAnimation(),
  },
  {
    'title': 'Everything is a Widget!',
    'subtitle': 'The core philosophy of Flutter\'s UI',
    'widget': const TwoColumnLayout(
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedListItem(
              index: 0,
              child: BulletPoint(
                  "In Flutter, almost everything is a widget - from a simple button to the entire screen layout.")),
          SizedBox(height: 16),
          AnimatedListItem(
              index: 1,
              child: BulletPoint(
                  "You build your UI by composing widgets inside other widgets, forming a 'Widget Tree'.")),
        ],
      ),
      right: WidgetTreeVisualizer(),
    ),
  },
  {
    'title': 'Stateless vs. Stateful Widgets',
    'subtitle': 'Understanding how Flutter handles state',
    'widget': const TwoColumnLayout(
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedListItem(
              index: 0,
              child: BulletPoint(
                  "StatelessWidget: Dumb widgets that don't change over time. Once drawn, they stay the same. E.g., an icon, a label.",
                  icon: Icons.crop_portrait)),
          SizedBox(height: 24),
          AnimatedListItem(
              index: 1,
              child: BulletPoint(
                  "StatefulWidget: Smart widgets that can change dynamically. They hold 'state' that can be updated, causing the widget to redraw.",
                  icon: Icons.dynamic_feed)),
        ],
      ),
      right: InteractiveCounterWidget(),
    ),
  },
  {
    'title': 'Module 1: Quiz',
    'subtitle': 'Tap to reveal the answer!',
    'widget': const QuizSlide(
      questions: [
        {
          'question': 'What is the core philosophy of Flutter\'s UI?',
          'hint': 'It\'s what everything is made of.',
          'answer': 'Everything is a Widget!',
        },
        {
          'question':
              'Which type of widget can change its appearance over time?',
          'hint': 'It holds a "state" object.',
          'answer': 'StatefulWidget',
        },
      ],
    ),
  },
  // Module 2
  {
    'title': 'Module 2: Intro to Dart',
    'subtitle': 'The Programming Language Behind Flutter',
    'widget': const TwoColumnLayout(
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedListItem(
            index: 0,
            child: BulletPoint(
                "Dart is a modern, object-oriented language developed by Google."),
          ),
          AnimatedListItem(
            index: 1,
            child: BulletPoint(
                "It's optimized for building fast, cross-platform apps."),
          ),
          AnimatedListItem(
            index: 2,
            child: BulletPoint(
                "Flutter uses Dart for all app logic and UI code."),
          ),
        ],
      ),
      right: PlatformIconsAnimation(),
    ),
  },
  {
    'title': 'Dart: Variables & Core Data Types',
    'subtitle': 'Storing information in your app',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Dart supports several core data types for storing information:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              BulletPoint('String: For text values.'),
              BulletPoint('int: For whole numbers.'),
              BulletPoint('double: For decimal numbers.'),
              BulletPoint('bool: For true/false values.'),
              BulletPoint('var: Lets Dart infer the type.'),
            ],
          ),
        ),
        right: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedCodeBlock('''
// Use 'String' for text
String name = "Flutter";

// Use 'int' for whole numbers
int version = 3;

// Use 'double' for numbers with decimals
double stars = 4.8;

// Use 'bool' for true/false values
bool isAwesome = true;

// Use 'var' to let Dart figure out the type
var myVariable = "Dart is smart!";
'''),
        ),
      ),
    ),
  },
  {
    'title': 'Dart: Collection Types',
    'subtitle': 'Storing groups of data',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Dart provides collections like List and Map to store multiple values:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              BulletPoint('List: An ordered collection of items.'),
              BulletPoint('Map: A collection of key-value pairs.'),
            ],
          ),
        ),
        right: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AnimatedCodeBlock('''
// List: An ordered collection of items.
List<String> planets = [
  "Mercury",
  "Venus",
  "Earth"
];

// Access items by index (starts at 0)
String firstPlanet = planets[0]; // "Mercury"
'''),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AnimatedCodeBlock('''
// Map: A collection of key-value pairs.
Map<String, String> capitals = {
  "USA": "Washington D.C.",
  "Japan": "Tokyo",
};

// Access values by key
String usCapital = capitals["USA"]!;
'''),
              ),
            ],
          ),
        ),
      ),
    ),
  },
  {
    'title': 'Dart: Operators',
    'subtitle': 'Performing actions on your data',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Operators let you perform calculations and comparisons:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              BulletPoint('Arithmetic: +, -, *, /'),
              BulletPoint('Equality: ==, !='),
              BulletPoint('Logical: &&, ||'),
            ],
          ),
        ),
        right: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedCodeBlock('''
// Arithmetic Operators
int a = 10 + 5; // 15
double b = 20 / 4; // 5.0

// Equality Operators
bool areEqual = (a == b); // false
bool notEqual = (10 != 5); // true

// Logical Operators
bool bothTrue = (areEqual && notEqual); // false
bool oneIsTrue = (areEqual || notEqual); // true
'''),
        ),
      ),
    ),
  },
  {
    'title': 'Dart: Functions',
    'subtitle': 'Reusable blocks of code',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Functions let you organize and reuse code. They can take parameters and return values:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        right: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedCodeBlock('''
// A simple function that takes a name and returns a greeting.
String sayHello(String name) {
  return "Hello, " + name + "!";
}

// Functions can have optional parameters.
void printMessage(String message, {String from = "Admin"}) {
  print("Message from " + from + ": " + message);
}

void main() {
  String greeting = sayHello("Student");
  print(greeting); // "Hello, Student!"

  printMessage("Welcome to Dart!");
  // "Message from Admin: Welcome to Dart!"
}
'''),
        ),
      ),
    ),
  },
  {
    'title': 'Dart Program: Shopping Bill',
    'subtitle': 'Let\'s write a simple program together',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Here\'s a real-world example: Calculate a shopping bill with tax.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        right: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedCodeBlock('''
// Calculates the total bill for a map of items and their prices.
double calculateTotalBill(Map<String, double> items) {
  double total = 0.0;

  // Loop through each item\'s price and add it to the total.
  for (double price in items.values) {
    total = total + price;
  }

  // Apply a 10% tax.
  double finalBill = total * 1.10;

  return finalBill;
}

void main() {
  Map<String, double> cart = {
    "Pizza": 15.99,
    "Soda": 2.50,
  };

  double myBill = calculateTotalBill(cart);

  // .toStringAsFixed(2) shows only 2 decimal places.
  print("Your total bill is: \$ " + myBill.toStringAsFixed(2));
  // Output: Your total bill is: \$ 20.34
}
'''),
        ),
      ),
    ),
  },
  {
    'title': 'Module 2 Summary',
    'subtitle': 'Key Takeaways',
    'widget': Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BulletPoint('Dart is the language behind Flutter.'),
        BulletPoint(
            'It has familiar types: String, int, double, bool, List, Map.'),
        BulletPoint(
            'Functions and operators help you organize and manipulate data.'),
        BulletPoint('You can now read and write basic Dart code!'),
        SizedBox(height: 24),
        Center(
            child: Icon(Icons.celebration, size: 80, color: Colors.cyanAccent)),
      ],
    ),
  },
  {
    'title': 'Module 2: Quiz',
    'subtitle': 'Tap to reveal the answer!',
    'widget': const QuizSlide(
      questions: [
        {
          'question':
              'What data type would you use to store a list of names?',
          'hint': 'It\'s an ordered collection.',
          'answer': 'List<String>',
        },
        {
          'question':
              'How do you define a function that returns a number?',
          'hint': 'Specify the return type before the function name.',
          'answer': 'int myFunction() { ... } or double myFunction() { ... }',
        },
      ],
    ),
  },
  // Module 3
  {
    'title': 'Module 3: Your First Flutter App',
    'subtitle': 'From Project Creation to "Hello World"',
    'widget': Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Let\'s see how a basic Flutter app is structured, from project creation to your first widget tree.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(child: AnimatedCodeBrackets()),
        ],
      ),
    ),
  },
  {
    'title': 'Project Folders & pubspec.yaml',
    'subtitle': 'Where your code and configurations live',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Your Flutter project has a specific folder structure. Here\'s what matters most:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AnimatedListItem(
                index: 0,
                child: BulletPoint(
                    "lib/: Contains all your Dart code. Your main logic goes here.",
                    icon: Icons.folder_special),
              ),
              AnimatedListItem(
                index: 1,
                child: BulletPoint(
                    "pubspec.yaml: The most important config file. Manage packages (dependencies) and assets (images, fonts) here.",
                    icon: Icons.settings),
              ),
              AnimatedListItem(
                index: 2,
                child: BulletPoint(
                    "ios/ & android/: Platform-specific project folders. You rarely need to edit these.",
                    icon: Icons.phone_android),
              ),
            ],
          ),
        ),
        right: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'The pubspec.yaml file manages dependencies and assets:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AnimatedCodeBlock('''
# pubspec.yaml
name: my_app

dependencies:
  flutter:
    sdk: flutter

  # Add packages from pub.dev here
  http: ^0.13.4
  google_fonts: ^2.1.0

flutter:
  uses-material-design: true

  # Register assets like images
  assets:
    - assets/images/logo.png
'''),
              ),
            ],
          ),
        ),
      ),
    ),
  },
  {
    'title': 'Anatomy of main.dart',
    'subtitle': 'The entry point of your Flutter app',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'The main.dart file is where your app starts. It defines the root widget and the app\'s entry point:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        right: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedCodeBlock('''
import 'package:flutter/material.dart';

// 1. The main() function is where your app starts.
void main() {
  // 2. runApp() inflates the given widget and attaches it to the screen.
  runApp(const MyApp());
}

// 3. MyApp is the root widget. It's the ancestor of all other widgets.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. MaterialApp wraps your app, providing core functionality.
    return MaterialApp(
      // 5. `home` defines the first screen the user sees.
      home: Scaffold(
        // The AppBar at the top of the screen
        appBar: AppBar(title: Text("My First App")),
        // The body of the screen
        body: Center(child: Text("Welcome!")),
      ),
    );
  }
}
'''),
        ),
      ),
    ),
  },
  {
    'title': 'Hello World!',
    'subtitle': 'Let\'s run your first app',
    'widget': Builder(
      builder: (context) => TwoColumnLayout(
        left: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Here\'s a minimal Flutter app that displays "Hello, World!" on the screen:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        right: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedCodeBlock('''
import 'package:flutter/material.dart';

void main() => runApp(const HelloWorldApp());

class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // The Scaffold widget provides a basic app layout structure.
      home: Scaffold(
        // The AppBar at the top of the screen
        appBar: AppBar(
          title: Text('Hello World App'),
          backgroundColor: Colors.deepPurple,
        ),
        // The body of the screen
        body: Center(
          child: Text(
            'Hello, World!',
            style: TextStyle(fontSize: 28, color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
'''),
        ),
      ),
    ),
  },
  {
    'title': 'Module 3: Quiz',
    'subtitle': 'Tap to reveal the answer!',
    'widget': const QuizSlide(
      questions: [
        {
          'question':
              'Which file is the most important for managing project dependencies?',
          'hint': 'It\'s a YAML file.',
          'answer': 'pubspec.yaml',
        },
        {
          'question':
              'What is the main entry point function for any Dart application?',
          'hint': 'It\'s where it all begins.',
          'answer': 'main()',
        },
      ],
    ),
  },
  {
    'title': 'Q&A and Next Steps',
    'subtitle': 'Thank you!',
    'widget': Builder(
      builder: (context) => Center(
          child: Icon(Icons.question_answer_outlined,
              size: 250,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.2))),
    ),
  },
];
