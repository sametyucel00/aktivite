import 'package:aktivite/shared/models/moderation_event.dart';

abstract class ModerationRepository {
  Stream<List<ModerationEvent>> watchTrustEvents(String userId);

  Future<void> createTrustEvent(ModerationEvent event);
}
