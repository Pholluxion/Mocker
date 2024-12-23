import 'package:server/src/pipe/pipe.dart';

class StepState extends Message<int> {
  StepState({
    super.name = 'step',
    super.value = 0,
  });

  @override
  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

class StepDistribution extends Pipe<StepState> {
  StepDistribution(super.socketChannel) : super(initialState: StepState()) {
    loop('step', stepSample);
  }

  void stepSample(Event event) {
    final value = event.getIntParam('step');
    final name = event.getStringParam('name');

    final state = StepState(name: name, value: value);

    emit(state);
  }
}
