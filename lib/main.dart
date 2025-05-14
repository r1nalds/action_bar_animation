import 'dart:async';

import 'package:action_bar_animation/container_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  runApp(const MaterialApp(home: Application()));
}

// https://github.com/flutter/website/blob/main/examples/_animation/basic_staggered_animation/lib/main.dart
class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  final GlobalKey _measureKey = GlobalKey();
  // - 56 is the height of action bar
  // - 16 * 2 is the total padding we want around Y axis. (16 for both top and bottom). This will allow us to Transform.translate the container below safe area.
  double _measuredChildHeight = 56 + 16 * 2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _measureKey.currentContext;
      if (context != null) {
        final size = context.size;
        if (size != null) {
          setState(() {
            _measuredChildHeight = size.height + _measuredChildHeight; // padding
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 3.0; // 1.0 is normal animation speed.
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _playAnimation();
        },
        child: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 32),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      // Widget that we will measure.
                      // Basically the same shit, but with assigned key for later acquiring the size of it.
                      Offstage(
                        offstage: true,
                        child: Container(
                          width: double.infinity,
                          child: ContainerContent(
                            key: _measureKey,
                          )
                        ),
                      ),
                      Expanded(
                        child: StaggerAnimation(
                          controller: _controller.view,
                          // Widget that we want to appear above the app bar.
                          // Identical widget to the measured one.
                          child: ContainerContent(),
                          targetHeight: _measuredChildHeight,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 54,
                    width: 175,
                    decoration: const ShapeDecoration(
                      color: Colors.black,
                      shape: StadiumBorder()
                    ),
                  ),
                ]
              )
            ),
          ),
        ),
      ),
    );
  }
}

// All the CURVES:  https://api.flutter.dev/flutter/animation/Curves-class.html
//
// Probably worth it to create a timeline of the custom animation.
// See: https://docs.flutter.dev/assets/images/docs/ui/animations/StaggeredAnimationIntervals.png
class StaggerAnimation extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> opacity;
  final Animation<double> width;
  final Animation<double> height;
  final Animation<Offset> transform;

  final Widget child;

  final double targetHeight;

  StaggerAnimation({
    super.key,
    required this.controller,
    required this.child,
    required this.targetHeight,
  }): 
  
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.100, curve: Curves.ease),
      ),
    ),
    width = Tween<double>(begin: 0.0, end: 250.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.125, 0.600, curve: Curves.fastEaseInToSlowEaseOut),
      ),
    ),
    height = Tween<double>(begin: 0.0, end: targetHeight).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.125, 0.500, curve: Curves.easeOutQuad),
      ),
    ),
    transform = Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 16.0)).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.125, 0.500, curve: Curves.fastOutSlowIn),
      ),
    );

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Transform.translate(
      offset: transform.value,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: opacity.value,
          child: Container(
            width: width.value,
            height: height.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
      child: child,
    );
  }
}