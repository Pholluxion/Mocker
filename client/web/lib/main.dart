import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Data {
  final String name;
  final dynamic value;

  Data({required this.name, required this.value});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(name: json['name'], value: json['value']);
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mocker',
      home: _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  late WebSocketChannel channel;
  @override
  void initState() {
    channel =
        WebSocketChannel.connect(Uri.parse('ws://localhost:8090/continuous'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                final Event event = Event(
                  event: 'startMQTTService',
                  parameters: [
                    Param(key: 'brokerHost', value: 'localhost'),
                    Param(key: 'brokerPort', value: '1883'),
                    Param(key: 'brokerTopic', value: 'device-messages'),
                  ],
                );
                channel.sink.add(json.encode(event));
              },
              child: const Icon(Icons.connect_without_contact),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                final Event event = Event(
                  event: 'stopMQTTService',
                  parameters: [],
                );
                channel.sink.add(json.encode(event));
              },
              child: const Icon(Icons.cancel),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                final Event event = Event(
                  event: 'stop',
                  parameters: [],
                );
                channel.sink.add(json.encode(event));
              },
              child: const Icon(Icons.stop),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                final Event event = Event(
                  event: 'normal',
                  parameters: [
                    Param(key: 'deviceUUID', value: '1'),
                    Param(key: 'topic', value: 'temperature'),
                    Param(key: 'times', value: '20'),
                    Param(key: 'duration', value: '1000'),
                    Param(key: 'name', value: 'normal'),
                    Param(key: 'mu', value: ' 10.0'),
                    Param(key: 'sigma', value: '2.0'),
                  ],
                );

                final raw = json.encode(event);

                channel.sink.add(raw);
              },
              child: const Icon(Icons.play_arrow),
            ),
          ],
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = Data.fromJson(json.decode(snapshot.data));
              return Text('${data.name}: ${data.value}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
