import 'package:data/data.dart';
import 'package:server/src/pipe/pipe.dart';

class DiscreteDistributionValue extends Message<int> {
  DiscreteDistributionValue({
    super.name = 'value',
    super.value = 0,
  });

  @override
  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

class DiscreteDistributionPipe extends Pipe<DiscreteDistributionValue> {
  DiscreteDistributionPipe(super.socketChannel) : super(initialState: DiscreteDistributionValue()) {
    /// Registering the handlers for the mocks.
    ///
    /// The `on` method registers a handler for an mock.
    /// The `loop` method registers a handler for an mock that repeats every duration.
    /// The `repeat` method registers a handler for an mock that repeats times every duration.
    loop('bernoulli', bernoulliSample);
    loop('binomial', binomialSample);
    loop('poisson', poissonSample);
    loop('uniform', uniformSample);
  }

  void uniformSample(Mock mock) {
    final a = mock.getIntParam('a');
    final b = mock.getIntParam('b');

    final value = UniformDiscreteDistribution(a, b).sample();

    final state = DiscreteDistributionValue(name: mock.name, value: value);

    emit(state);
  }

  void bernoulliSample(Mock mock) {
    final p = mock.getDoubleParam('p');

    final value = BernoulliDistribution(p).sample();

    final state = DiscreteDistributionValue(name: mock.name, value: value);

    emit(state);
  }

  void binomialSample(Mock mock) {
    final n = mock.getIntParam('n');
    final p = mock.getDoubleParam('p');

    final value = BinomialDistribution(n, p).sample();

    final state = DiscreteDistributionValue(name: mock.name, value: value);

    emit(state);
  }

  void poissonSample(Mock mock) {
    final lambda = mock.getDoubleParam('lambda');

    final value = PoissonDistribution(lambda).sample();

    final state = DiscreteDistributionValue(name: mock.name, value: value);

    emit(state);
  }
}
