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
///     remove external listener
///
/// Available at: https://gist.github.com/andrzejchm/02c1728b6f31a69fde2fb4e10b636060
class ExpandablePageView extends StatefulWidget {
  const ExpandablePageView({
    required this.children,
    super.key,
    this.controller,
    this.minHeight,
    this.physics = const PageScrollPhysics(),
    this.onPageChanged,
  });
  final List<Widget> children;
  final PageController? controller;
  final double? minHeight;
  final ScrollPhysics physics;
  final void Function(int)? onPageChanged;

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  late PageController _pageController;
  late List<double> _heights;

  // get current height based on current page
  double _getCurrentHeight() {
    if (_pageController.positions.isNotEmpty) {
      final currentHeight = _heights[_pageController.page!.round()];
      if (widget.minHeight != null && widget.minHeight! > currentHeight) {
        return widget.minHeight!;
      }
      return currentHeight;
    }
    return 0;
  }

  double get _currentHeight => _getCurrentHeight();

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    _pageController = widget.controller ?? PageController();
    super.initState();
  }

  @override
  void dispose() {
    // if controller is provided, don't auto-dispose
    if (widget.controller == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  // Non-animated page view
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _currentHeight,
      child: PageView(
        controller: _pageController,
        physics: widget.physics,
        onPageChanged: widget.onPageChanged,
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
            //needed, so that parent won't impose its constraints on the
            //children, thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) =>
                  setState(() => _heights[index] = size.height),
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
    required this.child,
    required this.onSizeChange,
    super.key,
  });
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
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
        child: SizedBox(
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
