import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../services/post_service.dart';
import '../../services/prayer_time_service.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/palestine_gradient_background.dart';
import '../../widgets/ramadan_countdown.dart';
import '../../widgets/wow_text.dart';
import '../admin/admin_media_upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificationSub;
  String? _lastShownNotificationId;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationSub = FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .listen(
        (snapshot) {
          if (!mounted || snapshot.docs.isEmpty) return;

          final doc = snapshot.docs.first;
          final data = doc.data();

          if (data['type'] != 'announcement') return;
          if (_dialogOpen) return;
          if (_lastShownNotificationId == doc.id) return;

          _lastShownNotificationId = doc.id;
          _dialogOpen = true;

          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text((data['title'] ?? '').toString()),
              content: Text((data['message'] ?? '').toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ).whenComplete(() {
            _dialogOpen = false;
          });
        },
        onError: (error) {
          debugPrint('Notifications listener skipped: $error');
        },
      );
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isLoggedIn ? 'Masjid Dashboard' : 'Guest Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Announcements',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.announcements);
            },
            icon: const Icon(Icons.campaign_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'login':
                  Navigator.pushNamed(context, AppRoutes.login);
                  break;
                case 'admin':
                  Navigator.pushNamed(context, AppRoutes.adminHome);
                  break;
                case 'settings':
                  Navigator.pushNamed(context, AppRoutes.settings);
                  break;
                case 'logout':
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.memberHome,
                      (_) => false,
                    );
                  }
                  break;
              }
            },
            itemBuilder: (_) => [
              if (!auth.isLoggedIn)
                const PopupMenuItem(
                  value: 'login',
                  child: Text('Login / Register'),
                ),
              if (auth.isAdmin)
                const PopupMenuItem(
                  value: 'admin',
                  child: Text('Admin Dashboard'),
                ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              if (auth.isLoggedIn)
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
            ],
          ),
        ],
      ),
      body: PalestineGradientBackground(
        child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await auth.refreshUser();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WowText('Assalamu Alaikum', size: 30),
                      const SizedBox(height: 10),
                      Text(
                        auth.isLoggedIn
                            ? 'Welcome ${auth.displayName}. Your masjid tools are ready.'
                            : 'Continue as guest or login once. Members and admins use the same login screen.',
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _BadgePill(
                            icon: Icons.mosque_rounded,
                            label: 'Live prayer tools',
                            color: cs.primary,
                          ),
                          _BadgePill(
                            icon: Icons.campaign_rounded,
                            label: 'Community updates',
                            color: cs.secondary,
                          ),
                          _BadgePill(
                            icon: Icons.menu_book_rounded,
                            label: '114 surahs',
                            color: Colors.black,
                          ),
                          if (auth.isAdmin)
                            const _BadgePill(
                              icon: Icons.admin_panel_settings_rounded,
                              label: 'Admin access',
                              color: Color(0xFFCE1126),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _NextPrayerCountdownCard(),
                const SizedBox(height: 18),
                Text(
                  'Quick Access',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.68,
                  children: [
                    const _DashboardTile(
                      title: 'Prayer Times',
                      subtitle: 'Today first',
                      icon: Icons.access_time_filled_rounded,
                      route: AppRoutes.prayerTimes,
                      color: Color(0xFF007A3D),
                      glowColor: Color(0x22007A3D),
                    ),
                    const _DashboardTile(
                      title: 'Next Salah',
                      subtitle: 'Real countdown',
                      icon: Icons.alarm_rounded,
                      route: AppRoutes.nextSalah,
                      color: Color(0xFFCE1126),
                      glowColor: Color(0x22CE1126),
                    ),
                    const _DashboardTile(
                      title: 'Quran Reader',
                      subtitle: 'All 114 surahs',
                      icon: Icons.menu_book_rounded,
                      route: AppRoutes.quran,
                      color: Color(0xFF111111),
                      glowColor: Color(0x22000000),
                    ),
                    const _DashboardTile(
                      title: 'Announcements',
                      subtitle: 'Masjid broadcasts',
                      icon: Icons.campaign_rounded,
                      route: AppRoutes.announcements,
                      color: Color(0xFFC9A227),
                      glowColor: Color(0x22C9A227),
                    ),
                    _DashboardTile(
                      title: auth.isLoggedIn ? 'Account' : 'Login',
                      subtitle: auth.isLoggedIn
                          ? (auth.isAdmin ? 'Admin signed in' : 'Member signed in')
                          : 'Login / Register',
                      icon: auth.isLoggedIn
                          ? Icons.verified_user_rounded
                          : Icons.person_rounded,
                      route: auth.isAdmin
                          ? AppRoutes.adminHome
                          : (auth.isLoggedIn
                              ? AppRoutes.memberHome
                              : AppRoutes.login),
                      color: const Color(0xFF1F5F8B),
                      glowColor: const Color(0x221F5F8B),
                    ),
                    _DashboardTile(
                      title: auth.isAdmin ? 'Admin Dashboard' : 'Settings',
                      subtitle: auth.isAdmin
                          ? 'Manage masjid'
                          : 'Notifications and app',
                      icon: auth.isAdmin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.settings_rounded,
                      route: auth.isAdmin
                          ? AppRoutes.adminHome
                          : AppRoutes.settings,
                      color: const Color(0xFF6B4C9A),
                      glowColor: const Color(0x226B4C9A),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.88),
                        const Color(0xFFEFF7F2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: cs.secondary.withValues(alpha: 0.10),
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: cs.secondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          auth.isLoggedIn
                              ? 'You are signed in. Pull down to refresh account status.'
                              : 'Guest mode is active. You can still browse prayer times, Quran, and announcements.',
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const RamadanCountdown(),
                const SizedBox(height: 18),
                Text(
                  'Community Wall',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                StreamBuilder(
                  stream: PostService.streamPosts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final posts = snapshot.data!;

                    if (posts.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                        child: const Text(
                          'No community posts yet.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    }

                    return Column(
                      children: posts.map((p) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white.withValues(alpha: 0.96),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 8,
                                color: Colors.black12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: cs.primary.withValues(alpha: 0.10),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            PostService.likePost(p.id);
                                          },
                                          icon: const Icon(
                                            Icons.favorite_rounded,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          '${p.likes}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () async {
                    await PostService.addPost(
                      'Masjid update ✨',
                      userName: auth.displayName.isEmpty
                          ? 'Member'
                          : auth.displayName,
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Post Message'),
                ),
                const SizedBox(height: 14),
                // 🔒 STORAGE DISABLED TEMPORARILY
                if (auth.isAdmin)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminMediaUploadScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload Media (Admin)'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NextPrayerCountdownCard extends StatefulWidget {
  const _NextPrayerCountdownCard();

  @override
  State<_NextPrayerCountdownCard> createState() =>
      _NextPrayerCountdownCardState();
}

class _NextPrayerCountdownCardState extends State<_NextPrayerCountdownCard> {
  Timer? _timer;
  String _nextPrayerName = '--';
  String _timeLabel = '--:--';
  String _countdown = '--:--:--';

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    final now = DateTime.now();
    final nextName = PrayerTimeService.instance.nextPrayerName(now: now) ?? '--';
    final nextDate = PrayerTimeService.instance.nextPrayerDateTime(now: now);

    String timeLabel = '--:--';
    String countdown = '--:--:--';

    if (nextDate != null) {
      final h = nextDate.hour.toString().padLeft(2, '0');
      final m = nextDate.minute.toString().padLeft(2, '0');
      timeLabel = '$h:$m';

      final diff = nextDate.difference(now);
      final totalSeconds = diff.inSeconds < 0 ? 0 : diff.inSeconds;
      final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
      countdown = '$hours:$minutes:$seconds';
    }

    if (!mounted) return;
    setState(() {
      _nextPrayerName = nextName;
      _timeLabel = timeLabel;
      _countdown = countdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled =
        context.watch<NotificationSettingsProvider>().countdownEnabled;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (!enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.20),
            ),
            child: Icon(
              Icons.alarm_rounded,
              size: 30,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Prayer',
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.90),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_nextPrayerName at $_timeLabel',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _countdown,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onPrimaryContainer,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;
  final Color glowColor;

  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.pushNamed(context, route),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.98),
                color.withValues(alpha: 0.09),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: glowColor,
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.18),
                        color.withValues(alpha: 0.07),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.18,
                    color: Colors.black.withValues(alpha: 0.72),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 22,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BadgePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: color.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}