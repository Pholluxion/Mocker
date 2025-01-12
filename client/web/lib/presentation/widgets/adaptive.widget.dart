import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocker/presentation/presentation.dart';

class AdaptiveWidget extends StatefulWidget {
  const AdaptiveWidget({
    super.key,
    required this.topChild,
    required this.bottomChild,
    this.dividerPosition = 0.5,
  });

  final Widget topChild;
  final Widget bottomChild;
  final double dividerPosition;

  @override
  State<AdaptiveWidget> createState() => _AdaptiveWidgetState();
}

class _AdaptiveWidgetState extends State<AdaptiveWidget> {
  late double dividerPosition;

  @override
  void initState() {
    dividerPosition = widget.dividerPosition;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dividerHeight = 16.0;
        final totalHeight = constraints.maxHeight;
        final topHeight = dividerPosition * totalHeight - dividerHeight / 2;
        final bottomHeight = totalHeight - topHeight - dividerHeight;

        return Column(
          children: [
            SizedBox(
              height: topHeight,
              width: constraints.maxWidth,
              child: widget.topChild,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) => onVerticalDragUpdate(details, totalHeight),
              child: _divider(dividerHeight),
            ),
            SizedBox(
              height: bottomHeight,
              child: widget.bottomChild,
            ),
          ],
        );
      },
    );
  }

  void onVerticalDragUpdate(DragUpdateDetails details, double totalHeight) {
    setState(() {
      dividerPosition += details.delta.dy / totalHeight;
      dividerPosition = dividerPosition.clamp(0.3, 0.7);
    });
  }

  Widget _divider(double dividerHeight) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return Container(
          color: state ? Colors.grey[800] : Colors.grey[200],
          child: Center(child: Icon(Icons.drag_handle, size: dividerHeight)),
        );
      },
    );
  }
}
