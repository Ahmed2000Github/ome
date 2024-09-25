import 'package:flutter_bloc/flutter_bloc.dart';

class OpenCloseDownloadIndicatorBloc extends Bloc<bool, bool> {
  OpenCloseDownloadIndicatorBloc() : super(false);
  @override
  Stream<bool> mapEventToState(bool event) async* {
    yield event;
  }
}
