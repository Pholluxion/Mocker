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
  DiscreteDistributionPipe(super.socketChannel)
      : super(initialState: DiscreteDistributionValue()) {
    /// Registering the handlers for the events.
    ///
    /// The `on` method registers a handler for an event.
    /// The `loop` method registers a handler for an event that repeats every duration.
    /// The `repeat` method registers a handler for an event that repeats times every duration.
    loop('bernoulli', bernoulliSample);
    loop('binomial', binomialSample);
    loop('poisson', poissonSample);
    loop('uniform', uniformSample);
  }

  void uniformSample(Event event) {
    final a = event.getIntParam('a');
    final b = event.getIntParam('b');
    final name = event.getStringParam('name');

    final value = UniformDiscreteDistribution(a, b).sample();

    final state = DiscreteDistributionValue(name: name, value: value);

    emit(state);
  }

  void bernoulliSample(Event event) {
    final p = event.getDoubleParam('p');
    final name = event.getStringParam('name');

    final value = BernoulliDistribution(p).sample();

    final state = DiscreteDistributionValue(name: name, value: value);

    emit(state);
  }

  void binomialSample(Event event) {
    final n = event.getIntParam('n');
    final p = event.getDoubleParam('p');
    final name = event.getStringParam('name');

    final value = BinomialDistribution(n, p).sample();

    final state = DiscreteDistributionValue(name: name, value: value);

    emit(state);
  }

  void poissonSample(Event event) {
    final lambda = event.getDoubleParam('lambda');
    final name = event.getStringParam('name');

    final value = PoissonDistribution(lambda).sample();

    final state = DiscreteDistributionValue(name: name, value: value);

    emit(state);
  }
}
