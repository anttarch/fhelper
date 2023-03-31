import 'package:flutter/material.dart';

/// Expandable Page View
/// Credits to:
///     andrzejchm - for base widget
///     MarceloFreitasx - for onPageChanged and controller fields
///     proninyaroslav - for refactored SizeReportingWidget widget
///
/// My additions:
///     physics - ScrollPhysics selection for PageView
///     minHeight - Sets a minimum height (allows full body swipes)
///     avoid auto disposal of externally provided controller
///     add a non-animated view (lighter-ish resource use)
///
/// Available at: https://gist.github.com/andrzejchm/02c1728b6f31a69fde2fb4e10b636060
class ExpandablePageView extends StatefulWidget {
  const ExpandablePageView({
    super.key,
    required this.children,
    this.controller,
    this.minHeight,
    this.physics = const PageScrollPhysics(),
    this.onPageChanged,
  });
  final List<Widget> children;
  final PageController? controller;
  final double? minHeight;
  final ScrollPhysics physics;
  final ValueChanged<int>? onPageChanged;

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;

  double _getCurrentHeight(double currentHeight) {
    if (widget.minHeight != null && widget.minHeight! > currentHeight) {
      return widget.minHeight!;
    }
    return currentHeight;
  }

  double get _currentHeight => _getCurrentHeight(_heights[_currentPage]);

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = widget.controller ?? PageController()
      ..addListener(() {
        final newPage = _pageController.page!.round();
        if (_currentPage != newPage) {
          if (widget.onPageChanged != null) {
            widget.onPageChanged?.call(newPage);
          }
          setState(() => _currentPage = newPage);
        }
      });
  }

  @override
  void dispose() {
    // if controller is provided, don't auto-dispose
    if (widget.controller == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return TweenAnimationBuilder<double>(
  //     curve: Curves.easeInOutCubic,
  //     duration: const Duration(milliseconds: 1),
  //     tween: Tween<double>(begin: _heights[0], end: _currentHeight),
  //     builder: (context, value, child) => SizedBox(height: value, child: child),
  //     child: PageView(
  //       controller: _pageController,
  //       physics: widget.physics,
  //       children: _sizeReportingChildren,
  //     ),
  //   );
  // }

  // Non-animated page view
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _currentHeight,
      child: PageView(
        controller: _pageController,
        physics: widget.physics,
        children: _sizeReportingChildren,
      ),
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap()
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            //needed, so that parent won't impose its constraints on the children, thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) => setState(() => _heights[index] = size.height),
              child: child,
            ),
          ),
        ),
      )
      .values
      .toList();
}

class SizeReportingWidget extends StatefulWidget {
  const SizeReportingWidget({
    super.key,
    required this.child,
    required this.onSizeChange,
  });
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  final _widgetKey = GlobalKey();
  Size _oldSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: _widgetKey,
          child: widget.child,
        ),
      ),
    );
  }

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) {
      return;
    }
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size!;
      widget.onSizeChange(size);
    }
  }
}
