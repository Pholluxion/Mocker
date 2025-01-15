import 'package:flutter_bloc/flutter_bloc.dart';

enum ChartState { resume, pause }

class ChartCubit extends Cubit<ChartState> {
  ChartCubit() : super(ChartState.resume);

  void pause() => emit(ChartState.pause);
  void resume() => emit(ChartState.resume);
}
