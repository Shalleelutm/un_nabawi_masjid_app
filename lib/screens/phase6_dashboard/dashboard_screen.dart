import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../services/prayer_time_service.dart';
import '../../services/sound_service.dart';
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
  late ConfettiController _confettiController;
  
  final List<String> _religiousTips = [
    '🤲 Make Dua after every prayer - it is the essence of worship',
    '📖 Recite Surah Al-Kahf every Friday',
    '🕌 2 Rakats of Duha prayer equals charity for 360 joints',
    '💤 Recite Ayat-ul-Kursi before sleeping for protection',
    '🌙 Tahajjud prayer is the key to Jannah',
    '📿 Say Subhanallah 33x, Alhamdulillah 33x, Allahu Akbar 34x after each prayer',
    '🤝 Smiling at your brother is charity',
    '🚶 Walking to the masjid increases your rank',
  ];
  String _currentTip = '';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _currentTip = _religiousTips[DateTime.now().day % _religiousTips.length];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationSub = FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
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
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('OK'),
      ),
    ],
  ),
).whenComplete(() {
  if (mounted) _dialogOpen = false;
});
      });
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _showWelcomeConfetti() {
    _confettiController.play();
    Future.delayed(const Duration(seconds: 3), () => _confettiController.stop());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isLoggedIn ? 'Masjid Dashboard' : 'Guest Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Announcements',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.announcements),
            icon: const Icon(Icons.campaign_rounded),
            splashRadius: 24,
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
                      context, AppRoutes.memberHome, (_) => false);
                  }
                  break;
              }
            },
            itemBuilder: (_) => [
              if (!auth.isLoggedIn) const PopupMenuItem(value: 'login', child: Text('Login / Register')),
              if (auth.isAdmin) const PopupMenuItem(value: 'admin', child: Text('Admin Dashboard')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              if (auth.isLoggedIn) const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SoundService.playAdhan();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Testing Adhan + Vibration! Check your phone!')),
          );
        },
        child: const Icon(Icons.volume_up),
      ),
      body: Stack(
        children: [
          PalestineGradientBackground(
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: () async {
                  await auth.refreshUser();
                  _showWelcomeConfetti();
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
                                : 'Continue as guest or login once.',
                            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _BadgePill(icon: Icons.mosque_rounded, label: 'Live prayer tools', color: cs.primary),
                              _BadgePill(icon: Icons.campaign_rounded, label: 'Community updates', color: cs.secondary),
                              _BadgePill(icon: Icons.menu_book_rounded, label: '114 surahs', color: Colors.black),
                              if (auth.isAdmin) const _BadgePill(icon: Icons.admin_panel_settings_rounded, label: 'Admin access', color: Color(0xFFCE1126)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentTip,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.orange]),
                        boxShadow: [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.announcements),
                        borderRadius: BorderRadius.circular(18),
                        child: const Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(child: Text('New Announcement Available!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const _NextPrayerCountdownCard(),
                    const SizedBox(height: 18),

                    Text('Quick Access', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.68,
                      children: [
                        const _DashboardTile(title: 'Prayer Times', subtitle: 'Today first', icon: Icons.access_time_filled_rounded, route: AppRoutes.prayerTimes, color: Color(0xFF007A3D), glowColor: Color(0x22007A3D)),
                        const _DashboardTile(title: 'Next Salah', subtitle: 'Real countdown', icon: Icons.alarm_rounded, route: AppRoutes.nextSalah, color: Color(0xFFCE1126), glowColor: Color(0x22CE1126)),
                        const _DashboardTile(title: 'Quran Reader', subtitle: 'All 114 surahs', icon: Icons.menu_book_rounded, route: AppRoutes.quran, color: Color(0xFF111111), glowColor: Color(0x22000000)),
                        const _DashboardTile(title: 'Announcements', subtitle: 'Masjid broadcasts', icon: Icons.campaign_rounded, route: AppRoutes.announcements, color: Color(0xFFC9A227), glowColor: Color(0x22C9A227)),
                        // REQUEST TILES - ONLY SHOW FOR LOGGED IN USERS
                        if (auth.isLoggedIn) ...[
                          const _DashboardTile(title: 'Send Request', subtitle: 'Message Admin', icon: Icons.message, route: '/createRequest', color: Color(0xFF2196F3), glowColor: Color(0x222196F3)),
                          const _DashboardTile(title: 'My Requests', subtitle: 'View Replies', icon: Icons.inbox, route: '/myRequests', color: Color(0xFF9C27B0), glowColor: Color(0x229C27B0)),
                        ],
                        const _DashboardTile(title: 'Zakat', subtitle: 'Calculate Zakat', icon: Icons.calculate, route: '/zakat', color: Color(0xFFF57C00), glowColor: Color(0x22F57C00)),
                        const _DashboardTile(title: 'Hijri Calendar', subtitle: 'Islamic Date', icon: Icons.calendar_month, route: '/hijriCalendar', color: Color(0xFF1E88E5), glowColor: Color(0x221E88E5)),
                        const _DashboardTile(title: 'Qibla', subtitle: 'Find Direction', icon: Icons.compass_calibration, route: '/qiblah', color: Color(0xFF4CAF50), glowColor: Color(0x224CAF50)),
                        const _DashboardTile(title: '99 Names', subtitle: 'Names of Allah', icon: Icons.star, route: '/namesOfAllah', color: Color(0xFF9C27B0), glowColor: Color(0x229C27B0)),
                        const _DashboardTile(title: 'Mosques', subtitle: 'Nearby Mosques', icon: Icons.mosque, route: '/mosques', color: Color(0xFF00BCD4), glowColor: Color(0x2200BCD4)),
                        const _DashboardTile(title: 'Masjid Gallery', subtitle: 'View Photos', icon: Icons.photo_library, route: '/gallery', color: Color(0xFFE91E63), glowColor: Color(0x22E91E63)),
                        _DashboardTile(title: auth.isLoggedIn ? 'Account' : 'Login', subtitle: auth.isLoggedIn ? (auth.isAdmin ? 'Admin signed in' : 'Member signed in') : 'Login / Register', icon: auth.isLoggedIn ? Icons.verified_user_rounded : Icons.person_rounded, route: auth.isAdmin ? AppRoutes.adminHome : (auth.isLoggedIn ? AppRoutes.memberHome : AppRoutes.login), color: const Color(0xFF1F5F8B), glowColor: const Color(0x221F5F8B)),
                        _DashboardTile(title: auth.isAdmin ? 'Admin Dashboard' : 'Settings', subtitle: auth.isAdmin ? 'Manage masjid' : 'Notifications and app', icon: auth.isAdmin ? Icons.admin_panel_settings_rounded : Icons.settings_rounded, route: auth.isAdmin ? AppRoutes.adminHome : AppRoutes.settings, color: const Color(0xFF6B4C9A), glowColor: const Color(0x226B4C9A)),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.95), const Color(0xFFFDF5E6)]),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        children: [
                          Container(width: 54, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: cs.secondary.withValues(alpha: 0.10)), child: Icon(Icons.format_quote_rounded, color: cs.secondary, size: 30)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📖 Hadith of the Day', style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('"The best among you are those who have the best manners and character."', style: TextStyle(fontStyle: FontStyle.italic, height: 1.4)),
                                const SizedBox(height: 4),
                                const Align(alignment: Alignment.centerRight, child: Text('- Sahih Bukhari', style: TextStyle(fontWeight: FontWeight.w600))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const RamadanCountdown(),
                    const SizedBox(height: 18),

                    const SizedBox(height: 14),
                    if (auth.isAdmin)
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMediaUploadScreen())),
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Upload Media (Admin)'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.green, Colors.red, Colors.amber, Colors.blue, Colors.purple],
              numberOfParticles: 20,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _BadgePill({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: color.withValues(alpha: 0.10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String title; final String subtitle; final IconData icon; final String route; final Color color; final Color glowColor;
  const _DashboardTile({required this.title, required this.subtitle, required this.icon, required this.route, required this.color, required this.glowColor});
  
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.pushNamed(context, route),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.98), color.withValues(alpha: 0.09)]),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16),
              BoxShadow(color: glowColor, blurRadius: 24, spreadRadius: 1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58, height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.07)]),
                    border: Border.all(color: color.withValues(alpha: 0.12)),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 14)],
                  ),
                  child: Icon(icon, color: color, size: 29),
                ),
                const SizedBox(height: 14),
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Align(alignment: Alignment.bottomRight, child: Icon(Icons.arrow_forward_rounded, size: 22, color: color)),
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
  @override State<_NextPrayerCountdownCard> createState() => _NextPrayerCountdownCardState();
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
    final enabled = context.watch<NotificationSettingsProvider>().countdownEnabled;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (!enabled) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [cs.primaryContainer, cs.tertiaryContainer]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18)],
      ),
      child: Row(
        children: [
          Container(width: 62, height: 62, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white.withValues(alpha: 0.20)), child: Icon(Icons.alarm_rounded, size: 30, color: cs.onPrimaryContainer)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Prayer', style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('$_nextPrayerName at $_timeLabel', style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(_countdown, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}