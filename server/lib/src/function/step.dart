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

  void stepSample(Mock mock) {
    final value = mock.getIntParam('step');

    final state = StepState(name: mock.name, value: value);

    emit(state);
  }
}
