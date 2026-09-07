import 'package:menfit_app/core/platform/sharing/share_plus_sharing_adapter.dart';
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sharing_providers.g.dart';

/// The app's single [SharingAdapter]. Widget tests override it with a
/// fake (`test/core/platform/sharing/fake_sharing_adapter.dart`) — no
/// test should ever reach the real share sheet.
@Riverpod(keepAlive: true)
SharingAdapter sharingAdapter(Ref ref) {
  return SharePlusSharingAdapter();
}
