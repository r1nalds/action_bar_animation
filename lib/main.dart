import 'dart:async';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
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
    timeDilation = 1.0; // 1.0 is normal animation speed.
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
                  StaggerAnimation(controller: _controller.view),
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

  StaggerAnimation({super.key, required this.controller}): 
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
    height = Tween<double>(begin: 0.0, end: 150.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.125, 0.500, curve: Curves.easeOutQuad),
      ),
    ),
    transform = Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 16.0)).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.125, 0.500, curve: Curves.ease),
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.indigo[300]!, width: 3),
              borderRadius: BorderRadius.circular(16)
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(builder: _buildAnimation, animation: controller);
  }
}