import 'package:data/data.dart';

import 'package:server/src/pipe/pipe.dart';
import 'package:server/src/utils/extensions.dart';

class ContinuousDistributionValue extends Message<double> {
  ContinuousDistributionValue({
    super.name = 'value',
    super.value = 0.0,
  });

  @override
  Map<String, dynamic> toJson() => {'name': name, 'value': value.fix(1)};

  @override
  Map<String, dynamic> format() => {name: value.fix(1)};
}

class ContinuousDistributionPipe extends Pipe<ContinuousDistributionValue> {
  ContinuousDistributionPipe(super.socketChannel)
      : super(initialState: ContinuousDistributionValue()) {
    /// Registering the handlers for the events.

    /// Generating a normal distribution stream.
    loop('normal', normalSample);

    /// Generating a normal distribution sample.
    on('normalSample', normalSample);

    /// Generating a uniform distribution stream.
    loop('uniform', uniformSample);

    /// Generating a uniform distribution sample.
    on('uniformSample', uniformSample);

    /// Generating an exponential distribution stream.
    loop('exponential', exponentialSample);

    /// Generating an exponential distribution sample.
    on('exponentialSample', exponentialSample);
  }

  void normalSample(Event event) {
    final mu = event.getDoubleParam('mu');
    final sigma = event.getDoubleParam('sigma');
    final name = event.getStringParam('name');

    final value = NormalDistribution(mu, sigma).sample();

    final state = ContinuousDistributionValue(name: name, value: value);

    emit(state);
  }

  void uniformSample(Event event) {
    final a = event.getDoubleParam('a');
    final b = event.getDoubleParam('b');
    final name = event.getStringParam('name');

    final value = UniformDistribution(a, b).sample();

    final state = ContinuousDistributionValue(name: name, value: value);

    emit(state);
  }

  void exponentialSample(Event event) {
    final lambda = event.getDoubleParam('lambda');
    final name = event.getStringParam('name');

    final value = ExponentialDistribution(lambda).sample();

    final state = ContinuousDistributionValue(name: name, value: value);

    emit(state);
  }
}
