import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocker/domain/domain.dart';
import 'package:mocker/presentation/presentation.dart';

class ConsoleView extends StatefulWidget {
  const ConsoleView({
    super.key,
    required this.stream,
    required this.color,
  });

  final Stream<Data> stream;
  final MaterialColor color;

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  late final ScrollController _scrollController;
  late final StreamSubscription _subscription;
  List<Data> buffer = [];

  @override
  void initState() {
    _subscription = widget.stream.listen(
      (event) {
        setState(() {
          if (buffer.length > 1000) {
            buffer.removeAt(0);
          }

          buffer.add(event);
        });
      },
    );
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (buffer.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return BlocListener<ChartCubit, ChartState>(
      listener: (context, state) {
        if (state == ChartState.pause) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          _subscription.pause();
        }

        if (state == ChartState.resume) {
          _subscription.resume();
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: buffer.length,
        itemBuilder: (context, index) {
          return Text(
            buffer[index].toString(),
            style: TextStyle(color: widget.color),
          );
        },
      ),
    );
  }
}
