// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ContainerContent extends StatelessWidget {
  final double opacity;

  const ContainerContent({
    super.key,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Flexible(child: Text("1234\n\n\n\n\n", softWrap: true, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class ContainerContent2 extends StatelessWidget {
  const ContainerContent2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children:  [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text("4/5 Putts",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
        
                  Flexible(
                    flex: 1,
                    child: Transform.translate(
                      offset: const Offset(0, -16),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text("until summary",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: LinearProgressIndicator(
                value: 0.8,
              ),
            )
          ],
        ),
      ),
    );
  }
}