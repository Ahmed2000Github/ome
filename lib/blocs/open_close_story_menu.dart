import 'package:flutter_bloc/flutter_bloc.dart';

class OpenCloseStoryThemeMenuBloc extends Bloc<bool, bool> {
  OpenCloseStoryThemeMenuBloc() : super(false);
  @override
  Stream<bool> mapEventToState(bool event) async* {
    yield event;
  }
}
