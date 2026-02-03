import 'package:equatable/equatable.dart';

abstract class ChartsEvent extends Equatable {
  const ChartsEvent();
  @override
  List<Object> get props => [];
}
class LoadCharts extends ChartsEvent {}
