import '../providers/notification_settings_provider.dart';
import 'fcm_service.dart';

class NotificationBridgeService {
  static Future<void> apply(NotificationSettingsProvider settings) async {
    if (settings.announcementNotificationsEnabled) {
      await FcmService.instance.subscribe('announcements');
    } else {
      await FcmService.instance.unsubscribe('announcements');
    }

    if (settings.eventNotificationsEnabled) {
      await FcmService.instance.subscribe('events');
    } else {
      await FcmService.instance.unsubscribe('events');
    }
  }
}