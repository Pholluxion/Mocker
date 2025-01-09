import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:shared/shared.dart';

import 'package:mocker/presentation/presentation.dart';

// final mock = Mock(
//   function: 'Temperature',
//   name: 'normal',
//   intervalMs: 1000,
//   parameters: [
//     Param(key: 'mu', value: '1.0'),
//     Param(key: 'sigma', value: '0.0'),
//   ],
//   mqttClientEnabled: true,
// );

class SourceCodeViewer<T> extends StatefulWidget {
  const SourceCodeViewer({
    super.key,
    required this.data,
  });

  final T data;

  @override
  State<SourceCodeViewer> createState() => _SourceCodeViewerState();
}

class _SourceCodeViewerState extends State<SourceCodeViewer> {
  late String code;
  double fontSize = 14.0;

  @override
  void initState() {
    code = YamlParser.jsonToYaml(widget.data.toJson());
    super.initState();
  }

  void _jsonToYaml() {
    Clipboard.setData(ClipboardData(text: code)).ignore();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        showCloseIcon: true,
        content: Text('Copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<ThemeCubit, bool>(
          builder: (context, state) {
            return SyntaxView(
              code: code,
              syntax: Syntax.YAML,
              syntaxTheme: state ? SyntaxTheme.vscodeDark() : SyntaxTheme.vscodeLight(),
              fontSize: fontSize,
              withZoom: false,
              withLinesCount: true,
              expanded: true,
              selectable: true,
            );
          },
        ),
        Positioned(
          right: 10.0,
          bottom: 10.0,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _jsonToYaml,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () {
                  if (fontSize >= 30.0) {
                    return;
                  }
                  setState(() {
                    fontSize += 2.0;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () {
                  if (fontSize <= 10.0) {
                    return;
                  }

                  setState(() {
                    fontSize -= 2.0;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    fontSize = 14.0;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
