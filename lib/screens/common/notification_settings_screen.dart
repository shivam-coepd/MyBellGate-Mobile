import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Master toggle
  bool _allNotificationsEnabled = true;

  // Category toggles: push / email / sms
  final Map<String, Map<String, bool>> _categorySettings = {
    'security_alerts': {'push': true, 'email': true, 'sms': false},
    'visitor_arrivals': {'push': true, 'email': false, 'sms': false},
    'notices_announcements': {'push': true, 'email': true, 'sms': false},
    'billing_payments': {'push': true, 'email': true, 'sms': true},
    'community_updates': {'push': true, 'email': false, 'sms': false},
    'maintenance_alerts': {'push': true, 'email': true, 'sms': false},
    'delivery_otp': {'push': true, 'email': false, 'sms': true},
  };

  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  // Sound & vibration
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _badgeCountEnabled = true;

  final Map<String, String> _categoryLabels = {
    'security_alerts': 'Security Alerts',
    'visitor_arrivals': 'Visitor Arrivals',
    'notices_announcements': 'Notices & Announcements',
    'billing_payments': 'Billing & Payments',
    'community_updates': 'Community Updates',
    'maintenance_alerts': 'Maintenance Alerts',
    'delivery_otp': 'Delivery & OTP',
  };

  final Map<String, IconData> _categoryIcons = {
    'security_alerts': Icons.shield_outlined,
    'visitor_arrivals': Icons.person_add_outlined,
    'notices_announcements': Icons.campaign_outlined,
    'billing_payments': Icons.receipt_long_outlined,
    'community_updates': Icons.groups_outlined,
    'maintenance_alerts': Icons.build_outlined,
    'delivery_otp': Icons.inventory_2_outlined,
  };

  final Map<String, String> _categoryDescriptions = {
    'security_alerts': 'Breach, panic, SOS and guard alerts',
    'visitor_arrivals': 'When a visitor arrives at your gate',
    'notices_announcements': 'Society notices and admin announcements',
    'billing_payments': 'Invoice generated, payment reminders & receipts',
    'community_updates': 'Events, polls and community posts',
    'maintenance_alerts': 'Water supply, power cut, lift maintenance',
    'delivery_otp': 'Package delivery OTP and courier updates',
  };

  Future<void> _pickQuietStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _quietStart,
    );
    if (picked != null) setState(() => _quietStart = picked);
  }

  Future<void> _pickQuietEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _quietEnd,
    );
    if (picked != null) setState(() => _quietEnd = picked);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  void _saveSettings() {
    AppSnackbar.show(
      context: context,
      message: 'Notification preferences saved successfully',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Master Toggle ─────────────────────────────────────────────
            _buildSectionCard(
              theme,
              children: [
                SwitchListTile(
                  title: Text(
                    'All Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Master switch for all notification types',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _allNotificationsEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() {
                    _allNotificationsEnabled = v;
                    if (!v) {
                      for (final cat in _categorySettings.keys) {
                        _categorySettings[cat]!['push'] = false;
                        _categorySettings[cat]!['email'] = false;
                        _categorySettings[cat]!['sms'] = false;
                      }
                    }
                  }),
                ),
              ],
            ),

            // ── Notification Categories ──────────────────────────────────
            Padding(
              padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h),
              child: Text(
                'NOTIFICATION CATEGORIES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ..._categorySettings.entries.map((entry) {
              final key = entry.key;
              final settings = entry.value;
              return _buildSectionCard(
                theme,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _categoryIcons[key]!,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _categoryLabels[key]!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                _categoryDescriptions[key]!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  Row(
                    children: [
                      _buildChannelChip(theme, 'Push', settings['push']!, (v) {
                        if (_allNotificationsEnabled) {
                          setState(() => settings['push'] = v);
                        }
                      }),
                      _buildChannelChip(theme, 'Email', settings['email']!, (
                        v,
                      ) {
                        if (_allNotificationsEnabled) {
                          setState(() => settings['email'] = v);
                        }
                      }),
                      _buildChannelChip(theme, 'SMS', settings['sms']!, (v) {
                        if (_allNotificationsEnabled) {
                          setState(() => settings['sms'] = v);
                        }
                      }),
                    ],
                  ),
                ],
              );
            }),

            // ── Quiet Hours ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h),
              child: Text(
                'QUIET HOURS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _buildSectionCard(
              theme,
              children: [
                SwitchListTile(
                  title: Text(
                    'Do Not Disturb',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Mute all non-critical notifications during set hours',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _quietHoursEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _quietHoursEnabled = v),
                ),
                if (_quietHoursEnabled) ...[
                  Divider(
                    height: 0,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimePicker(
                          theme,
                          'From',
                          _formatTime(_quietStart),
                          _pickQuietStartTime,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        _buildTimePicker(
                          theme,
                          'To',
                          _formatTime(_quietEnd),
                          _pickQuietEndTime,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // ── Sound & Display ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h),
              child: Text(
                'SOUND & DISPLAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _buildSectionCard(
              theme,
              children: [
                SwitchListTile(
                  title: Text(
                    'Notification Sound',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  value: _soundEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'Vibration',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  value: _vibrationEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _vibrationEnabled = v),
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'Badge Count',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  value: _badgeCountEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _badgeCountEnabled = v),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // ── Save Button ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme, {required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: theme.colorScheme.surface,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildChannelChip(
    ThemeData theme,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: value
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value ? Icons.check_circle : Icons.check_circle_outline,
                size: 14,
                color: value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: value
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    ThemeData theme,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
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
