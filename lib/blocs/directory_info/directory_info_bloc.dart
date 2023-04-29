import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ome/enums/state_status.dart';
import 'package:ome/services/file_services.dart';

part 'directory_info_event.dart';
part 'directory_info_state.dart';

class DirectoryInfoBloc extends Bloc<DirectoryInfoEvent, DirectoryInfoState> {
  DirectoryInfoBloc()
      : super(DirectoryInfoState(status: StateStatus.NONE, numberOfFiles: 0));

  FileServices get fileServices => GetIt.I<FileServices>();
  @override
  Stream<DirectoryInfoState> mapEventToState(DirectoryInfoEvent event) async* {
    yield DirectoryInfoState(status: StateStatus.LOADING, numberOfFiles: 0);
    int result = await fileServices.getNumberOfFiles();
    yield DirectoryInfoState(status: StateStatus.LOADED, numberOfFiles: result);
  }
}
