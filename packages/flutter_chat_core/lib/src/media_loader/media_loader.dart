import '../storage/storage.dart';

abstract class MediaLoader {
  Stream<int> download(String url, Storage storage);
}
