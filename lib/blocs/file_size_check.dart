import 'package:flutter_bloc/flutter_bloc.dart';

class FileCheckSizeBloc extends Bloc<bool, bool> {
  FileCheckSizeBloc() : super(false);
  @override
  Stream<bool> mapEventToState(bool event) async* {
    yield event;
  }
}
