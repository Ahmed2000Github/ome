import 'package:flutter_bloc/flutter_bloc.dart';

class OpenCloseBackgroundImagesBloc extends Bloc<bool, bool> {
  OpenCloseBackgroundImagesBloc() : super(false);
  @override
  Stream<bool> mapEventToState(bool event) async* {
    yield event;
  }
}
