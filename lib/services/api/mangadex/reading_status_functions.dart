import 'package:mangadex_library/models/common/reading_status.dart';

import '../../../utils/utils.dart';

class ReadingStatusFunctions {
  static ReadingStatus? checkReadingStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return null;
    } else {
      return FludexUtils.statusStringToEnum(status.toLowerCase());
    }
  }
}
