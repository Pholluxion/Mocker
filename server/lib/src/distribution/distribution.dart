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
  DistributionMock({this.messages = const []});

  final List<MockMessage> messages;

  @override
  Map<String, dynamic> format() => Map.fromEntries(
        messages.map((e) => MapEntry(e.name, e.value)),
      );

  @override
  Object? toJson() => messages.map((message) => message.toJson()).toList();

  DistributionMock copyWith({
    List<MockMessage>? messages,
  }) {
    return DistributionMock(
      messages: messages ?? this.messages,
    );
  }

  @override
  void add(MockMessage message) => messages.add(message);
}

class DistributionPipe extends Pipe<DistributionMock> {
  DistributionPipe(super.socketChannel) : super(initialState: DistributionMock()) {
    /// Registering the handlers for the mocks.
    ///
    /// The `on` method registers a handler for an mock.
    /// The `loop` method registers a handler for an mock that repeats every duration.
    /// The `repeat` method registers a handler for an mock that repeats times every duration.
    ///

    /// Discrete distribution samples.
    // loop('/discrete/bernoulli', discreteBernoulliSample);
    // loop('/discrete/binomial', discreteBinomialSample);
    // loop('/discrete/poisson', discretePoissonSample);
    // loop('/discrete/uniform', discreteUniformSample);

    // /// Continuous distribution samples.
    // loop('/continuous/normal', continuousNormalSample);
    // loop('/continuous/uniform', continuousUniformSample);
    // loop('/continuous/exponential', continuousExponentialSample);

    loop('mux', mux);
  }

  void mux(Mock mock) {
    List<MockMessage> updatedMessages = [];

    for (final fn in mock.functions) {
      switch (fn.handler) {
        case '/discrete/bernoulli':
          updatedMessages.add(discreteBernoulliSample(fn));
          break;
        case '/discrete/binomial':
          updatedMessages.add(discreteBinomialSample(fn));
          break;
        case '/discrete/poisson':
          updatedMessages.add(discretePoissonSample(fn));
          break;
        case '/discrete/uniform':
          updatedMessages.add(discreteUniformSample(fn));
          break;
        case '/continuous/normal':
          updatedMessages.add(continuousNormalSample(fn));
          break;
        case '/continuous/uniform':
          updatedMessages.add(continuousUniformSample(fn));
          break;
        case '/continuous/exponential':
          updatedMessages.add(continuousExponentialSample(fn));
          break;
        default:
          break;
      }
    }

    emit(state.copyWith(messages: updatedMessages));
  }

  DiscreteDistributionValue discreteUniformSample(FunctionModel fn) {
    final a = fn.getIntParam('a');
    final b = fn.getIntParam('b');
    final name = fn.getStringParam('name');

    final value = UniformDiscreteDistribution(a, b).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  DiscreteDistributionValue discreteBernoulliSample(FunctionModel fn) {
    final p = fn.getDoubleParam('p');
    final name = fn.getStringParam('name');

    final value = BernoulliDistribution(p).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  DiscreteDistributionValue discreteBinomialSample(FunctionModel fn) {
    final n = fn.getIntParam('n');
    final p = fn.getDoubleParam('p');
    final name = fn.getStringParam('name');

    final value = BinomialDistribution(n, p).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  DiscreteDistributionValue discretePoissonSample(FunctionModel fn) {
    final lambda = fn.getDoubleParam('lambda');
    final name = fn.getStringParam('name');

    final value = PoissonDistribution(lambda).sample();

    return DiscreteDistributionValue(name: name, value: value);
  }

  /// Continuous distribution samples.

  ContinuousDistributionValue continuousNormalSample(FunctionModel fn) {
    final mu = fn.getDoubleParam('mu');
    final sigma = fn.getDoubleParam('sigma');
    final name = fn.getStringParam('name');

    final value = NormalDistribution(mu, sigma).sample();

    return ContinuousDistributionValue(name: name, value: value.fix(1));
  }

  ContinuousDistributionValue continuousUniformSample(FunctionModel fn) {
    final a = fn.getDoubleParam('a');
    final b = fn.getDoubleParam('b');
    final name = fn.getStringParam('name');

    final value = UniformDistribution(a, b).sample();

    return ContinuousDistributionValue(name: name, value: value.fix(1));
  }

  ContinuousDistributionValue continuousExponentialSample(FunctionModel fn) {
    final lambda = fn.getDoubleParam('lambda');
    final name = fn.getStringParam('name');

    final value = ExponentialDistribution(lambda).sample();

    return ContinuousDistributionValue(name: name, value: value.fix(1));
  }
}
