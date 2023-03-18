import 'package:flutter/material.dart';

import 'drawer_item.dart';

typedef DrawerPageBuilder = Widget Function(VoidCallback);

class HiddenDrawerView extends StatefulWidget {
  final List<DrawerPageBuilder> pages;
  final List<Widget> drawerItems;
  final double scale;
  final Duration animationDuration;
  final Curve animationCurve;
  final Image? background;

  const HiddenDrawerView(
      {Key? key,
      required this.pages,
      required this.drawerItems,
      this.animationDuration = const Duration(milliseconds: 300),
      this.scale = 0.7,
      this.animationCurve = Curves.easeIn,
      Image? background})
      : background = background,
        assert(pages.length == drawerItems.length,
            "pages length must be equal to drawer items length"),
        super(key: key);

  @override
  State<HiddenDrawerView> createState() => _HiddenDrawerViewState();
}

class _HiddenDrawerViewState extends State<HiddenDrawerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> scaleAnimation;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        lowerBound: 0.0,
        upperBound: 1.0);
    scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
        CurvedAnimation(
            parent: _animationController, curve: widget.animationCurve));
    _currentIndex.addListener(() {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void toggleAnimation() {
    switch (_animationController.status) {
      case AnimationStatus.completed:
        {
          _animationController.reverse();
          break;
        }
      case AnimationStatus.dismissed:
        {
          _animationController.forward();
          break;
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          widget.background ?? const SizedBox(),
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, index, _) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildDrawItems(widget.drawerItems, index),
                  ),
                );
              }),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.scale(
              scale: scaleAnimation.value,
              alignment: Alignment.centerRight,
              child: Transform.rotate(
                alignment: Alignment.bottomRight,
                angle: _animationController.value * .1,
                child: child,
              ),
            ),
            child: ValueListenableBuilder<int>(
                valueListenable: _currentIndex,
                builder: (context, index, _) {
                  return widget.pages[index](toggleAnimation);
                }),
          ),
        ],
      ),
    );
  }

  List<Widget> buildDrawItems(List<Widget> items, int value) {
    final result = <Widget>[];
    result.add(IconButton(
        onPressed: () => _animationController.reverse(),
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        )));
    result.add(const Spacer());
    for (int i = 0; i < items.length; i++) {
      result.add(GestureDetector(
          onTap: () => _currentIndex.value = i,
          child: DrawerItem(content: items[i], isCurrent: i == value)));
    }
    result.add(const Spacer());
    return result;
  }
}
