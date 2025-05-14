import 'package:flutter/material.dart';

class ContainerContent extends StatelessWidget {
  const ContainerContent({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(child: Text("1234\n\n\n\n\n", softWrap: true, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}