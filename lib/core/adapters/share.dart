import 'share_adapter.dart';
import 'share_mobile.dart' if (dart.library.html) 'share_web.dart';

// Export the adapter classes so they're available
export 'share_mobile.dart' if (dart.library.html) 'share_web.dart';

ShareAdapter getShareAdapter() {
  // Use conditional import to get the right adapter
  // On mobile: MobileShareAdapter
  // On web: WebShareAdapter (imported as MobileShareAdapter due to conditional import)
  return createShareAdapter();
}
