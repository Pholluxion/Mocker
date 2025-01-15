import 'package:data/data.dart';
import 'package:server/src/pipe/pipe.dart';
import 'package:server/src/utils/utils.dart';

class DiscreteDistributionValue extends MockMessage<int> {
  DiscreteDistributionValue({
    required super.name,
    required super.value,
  });
}

class ContinuousDistributionValue extends MockMessage<double> {
  ContinuousDistributionValue({
    required super.name,
    required super.value,
  });
}

class DistributionMock extends MultiMessage {
  DistributionMock({
    List<MockMessage>? messages,
  }) : super(messages ?? []);

  DistributionMock copyWith({List<MockMessage>? messages}) {
    return DistributionMock(messages: messages ?? this.messages);
  }
}

class DistributionPipe extends Pipe<DistributionMock> {
  DistributionPipe(super.socketChannel) : super(initialState: DistributionMock()) {
    loop('mux', mux);
  }

  void mux(Mock mock) {
    final handlers = {
      '/discrete/bernoulli': discreteBernoulliSample,
      '/discrete/binomial': discreteBinomialSample,
      '/discrete/poisson': discretePoissonSample,
      '/discrete/uniform': discreteUniformSample,
      '/continuous/normal': continuousNormalSample,
      '/continuous/uniform': continuousUniformSample,
      '/continuous/exponential': continuousExponentialSample,
    };

    final updatedMessages = mock.functions
        .map((fn) {
          if (!fn.enabled) {
            return fn;
          }

          return handlers[fn.handler]?.call(fn);
        })
        .whereType<MockMessage>()
        .toList();

    if (updatedMessages.isNotEmpty) {
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  DiscreteDistributionValue discreteUniformSample(Runner fn) {
    final a = fn.getIntParam('a');
    final b = fn.getIntParam('b');
    final name = fn.getStringParam('name');

    final value = UniformDiscreteDistribution(a, b).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  DiscreteDistributionValue discreteBernoulliSample(Runner fn) {
    final p = fn.getDoubleParam('p');
    final name = fn.getStringParam('name');

    final value = BernoulliDistribution(p).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  DiscreteDistributionValue discreteBinomialSample(Runner fn) {
    final n = fn.getIntParam('n');
    final p = fn.getDoubleParam('p');
    final name = fn.getStringParam('name');

    final value = BinomialDistribution(n, p).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  DiscreteDistributionValue discretePoissonSample(Runner fn) {
    final lambda = fn.getDoubleParam('lambda');
    final name = fn.getStringParam('name');

    final value = PoissonDistribution(lambda).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  /// Continuous distribution samples.

  ContinuousDistributionValue continuousNormalSample(Runner fn) {
    final mu = fn.getDoubleParam('mu');
    final sigma = fn.getDoubleParam('sigma');
    final name = fn.getStringParam('name');

    final value = NormalDistribution(mu, sigma).sample();

    return ContinuousDistributionValue(name: name, value: value.fix(1));
  }

  ContinuousDistributionValue continuousUniformSample(Runner fn) {
    final a = fn.getDoubleParam('a');
    final b = fn.getDoubleParam('b');
    final name = fn.getStringParam('name');

    final value = UniformDistribution(a, b).sample();

    return ContinuousDistributionValue(name: name, value: value.fix(1));
  }

  ContinuousDistributionValue continuousExponentialSample(Runner fn) {
    final lambda = fn.getDoubleParam('lambda');
    final name = fn.getStringParam('name');

    final value = ExponentialDistribution(lambda).sample();

    return ContinuousDistributionValue(name: name, value: value.fix(1));
  }
}
