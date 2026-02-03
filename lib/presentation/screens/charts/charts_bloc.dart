import 'package:flutter_bloc/flutter_bloc.dart';

import 'charts_event.dart';
import 'charts_state.dart';

class ChartsLoaded extends ChartsState {}

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  ChartsBloc() : super(ChartsLoaded()) {
    on<LoadCharts>(_onLoadCharts);
  }

  Future<void> _onLoadCharts(
    LoadCharts event,
    Emitter<ChartsState> emit,
  ) async {
    emit(ChartsLoaded());
  }
}
