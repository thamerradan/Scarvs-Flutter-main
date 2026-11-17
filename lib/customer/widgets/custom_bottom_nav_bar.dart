// شريط التنقل السفلي المنحني المتحرك المتوافق مع التصميم المرجعي ومع اتجاه RTL العربي.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';

class LinearPointCurve extends Curve {
  final double pIn;
  final double pOut;

  const LinearPointCurve(this.pIn, this.pOut);

  @override
  double transform(double x) {
    final lowerScale = pOut / pIn;
    final upperScale = (1.0 - pOut) / (1.0 - pIn);
    final upperOffset = 1.0 - upperScale;
    return x < pIn ? x * lowerScale : x * upperScale + upperOffset;
  }
}

class BackgroundCurvePainter extends CustomPainter {
  static const _radiusTop = 50.0;
  static const _radiusBottom = 30.0;
  static const _horizontalControlTop = 0.6;
  static const _horizontalControlBottom = 0.5;
  static const _pointControlTop = 0.35;
  static const _pointControlBottom = 0.85;
  static const _topY = -60.0;
  static const _bottomY = 0.0;
  static const _topDistance = 0.0;
  static const _bottomDistance = 10.0;

  final double _x;
  final double _normalizedY;
  final Color _color;

  BackgroundCurvePainter(double x, double normalizedY, Color color)
      : _x = x,
        _normalizedY = normalizedY,
        _color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final norm = const LinearPointCurve(0.5, 2.0).transform(_normalizedY) / 5;

    final radius =
        Tween<double>(begin: _radiusTop, end: _radiusBottom).transform(norm);
    final anchorControlOffset = Tween<double>(
            begin: radius * _horizontalControlTop,
            end: radius * _horizontalControlBottom)
        .transform(const LinearPointCurve(0.5, 0.75).transform(norm));
    final dipControlOffset = Tween<double>(
            begin: radius * _pointControlTop, end: radius * _pointControlBottom)
        .transform(const LinearPointCurve(0.5, 0.8).transform(norm));
    final y = Tween<double>(begin: _topY, end: _bottomY)
        .transform(const LinearPointCurve(0.2, 0.7).transform(norm));
    final dist = Tween<double>(begin: _topDistance, end: _bottomDistance)
        .transform(const LinearPointCurve(0.5, 0.0).transform(norm));
    final x0 = _x - dist / 2;
    final x1 = _x + dist / 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x0 - radius, 0)
      ..cubicTo(
          x0 - radius + anchorControlOffset, 0, x0 - dipControlOffset, y, x0, y)
      ..lineTo(x1, y)
      ..cubicTo(x1 + dipControlOffset, y, x1 + radius - anchorControlOffset, 0,
          x1 + radius, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    final paint = Paint()..color = _color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BackgroundCurvePainter oldPainter) {
    return _x != oldPainter._x ||
        _normalizedY != oldPainter._normalizedY ||
        _color != oldPainter._color;
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

class EcommerceBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItemData> items;
  final bool themeFlag;

  const EcommerceBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    required this.themeFlag,
  });

  @override
  State<EcommerceBottomNavigationBar> createState() =>
      _EcommerceBottomNavigationBarState();
}

class _EcommerceBottomNavigationBarState
    extends State<EcommerceBottomNavigationBar> with TickerProviderStateMixin {
  late AnimationController _xController;
  late AnimationController _yController;

  @override
  void initState() {
    super.initState();
    _xController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    );
    _yController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    );

    Listenable.merge([_xController, _yController]).addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _xController.value = _indexToPosition(widget.selectedIndex) /
        MediaQuery.of(context).size.width;
    _yController.value = 1.0;
  }

  @override
  void didUpdateWidget(EcommerceBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  double _getButtonContainerWidth() {
    double width = MediaQuery.of(context).size.width;
    if (width > 420.0) {
      width = 420.0;
    }
    return width;
  }

  double _indexToPosition(int index) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final buttonCount = widget.items.length.toDouble();
    final appWidth = MediaQuery.of(context).size.width;
    final buttonsWidth = _getButtonContainerWidth();
    final startX = (appWidth - buttonsWidth) / 2;

    final effectiveIndex = isRtl ? (widget.items.length - 1 - index) : index;

    return startX +
        effectiveIndex.toDouble() * buttonsWidth / buttonCount +
        buttonsWidth / (buttonCount * 2.0);
  }

  void _animateTo(int index) {
    _yController.value = 1.0;
    _xController.animateTo(
      _indexToPosition(index) / MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _yController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        );
      }
    });
    _yController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
    );
  }

  void _handlePressed(int index) {
    if (widget.selectedIndex == index || _xController.isAnimating) return;
    widget.onItemSelected(index);
    _animateTo(index);
  }

  Widget _buildBackground() {
    final barColor = widget.themeFlag ? AppColors.mirage : Colors.white;
    const inCurve = ElasticOutCurve(0.38);

    return CustomPaint(
      painter: BackgroundCurvePainter(
        _xController.value * MediaQuery.of(context).size.width,
        Tween<double>(
          begin: Curves.easeInExpo.transform(_yController.value),
          end: inCurve.transform(_yController.value),
        ).transform(_yController.velocity.sign * 0.5 + 0.5),
        barColor,
      ),
    );
  }

  Widget _buildIcon(NavItemData item, bool isSelected, int index) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => _handlePressed(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          alignment: isSelected ? Alignment.topCenter : Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                height: isSelected ? 46 : 26,
                width: isSelected ? 46 : 26,
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (widget.themeFlag ? Colors.white : AppColors.rawSienna)
                      : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (widget.themeFlag ? Colors.white : AppColors.rawSienna)
                                .withOpacity(0.35),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                  shape: BoxShape.circle,
                ),
                child: Opacity(
                  opacity:
                      isSelected ? _yController.value.clamp(0.0, 1.0) : 1.0,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: isSelected ? 22 : 24,
                    color: isSelected
                        ? (widget.themeFlag ? AppColors.mirage : Colors.white)
                        : (widget.themeFlag
                            ? Colors.white70
                            : const Color(0xff797878)),
                  ),
                ),
              ),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  top: isSelected ? -4 : -2,
                  right: isSelected ? -4 : -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${item.badgeCount! > 99 ? "99+" : item.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;
    const height = 65.0;

    return SizedBox(
      width: appSize.width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            width: appSize.width,
            height: height - 10,
            child: _buildBackground(),
          ),
          Positioned(
            left: (appSize.width - _getButtonContainerWidth()) / 2,
            top: 0,
            width: _getButtonContainerWidth(),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                widget.items.length,
                (i) => _buildIcon(
                  widget.items[i],
                  widget.selectedIndex == i,
                  i,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
