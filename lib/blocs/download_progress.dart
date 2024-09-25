import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadProgressBloc extends Bloc<double, double> {
  DownloadProgressBloc() : super(0);
  @override
  Stream<double> mapEventToState(double event) async* {
    yield event;
  }
}
