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
  ContinuousDistributionPipe(super.socketChannel) : super(initialState: ContinuousDistributionValue()) {
    /// Registering the handlers for the mocks.

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

  void normalSample(Mock mock) {
    final mu = mock.getDoubleParam('mu');
    final sigma = mock.getDoubleParam('sigma');

    final value = NormalDistribution(mu, sigma).sample();

    final state = ContinuousDistributionValue(name: mock.name, value: value);

    emit(state);
  }

  void uniformSample(Mock mock) {
    final a = mock.getDoubleParam('a');
    final b = mock.getDoubleParam('b');

    final value = UniformDistribution(a, b).sample();

    final state = ContinuousDistributionValue(name: mock.name, value: value);

    emit(state);
  }

  void exponentialSample(Mock mock) {
    final lambda = mock.getDoubleParam('lambda');

    final value = ExponentialDistribution(lambda).sample();

    final state = ContinuousDistributionValue(name: mock.name, value: value);

    emit(state);
  }
}
