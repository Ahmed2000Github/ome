import 'package:flutter_bloc/flutter_bloc.dart';

class OpenCloseMediaBloc extends Bloc<bool, bool> {
  OpenCloseMediaBloc() : super(false);
  @override
  Stream<bool> mapEventToState(bool event) async* {
    yield event;
  }
}
