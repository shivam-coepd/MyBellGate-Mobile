import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _pinLockEnabled = false;
  bool _showOnlineStatus = true;
  bool _profileVisible = true;
  bool _activityVisible = true;

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, sSet) => Container(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: Theme.of(sCtx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Enter your current password and a new strong password',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () =>
                          sSet(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () => sSet(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  validator: (v) {
                    if (v != newCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          showDialog(
                            context: ctx,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          await context.read<UserRepository>().changePassword(
                            currentCtrl.text,
                            newCtrl.text,
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx); // dismiss loading
                          }
                          if (ctx.mounted) {
                            Navigator.pop(ctx); // dismiss bottom sheet
                          }

                          if (mounted) {
                            // _showSnackBar(
                            //   'Password changed successfully',
                            //   color: Colors.green,
                            // );
                            AppSnackbar.show(
                              context: context,
                              message: 'Password changed successfully',
                              type: SnackBarType.success,
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            Navigator.pop(ctx); // dismiss loading
                          }
                          if (mounted) {
                            // _showSnackBar(e.toString().replaceAll('Exception: ', ''), color: Colors.red);
                            AppSnackbar.show(
                              context: context,
                              message: e.toString().replaceAll(
                                'Exception: ',
                                '',
                              ),
                              type: SnackBarType.error,
                              position: SnackBarPosition.top,
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Update Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSetPinSheet() {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 20.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Set PIN Lock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                'Set a 4 or 6-digit PIN to lock the app',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter PIN',
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length != 4 && v.length != 6) {
                    return 'PIN must be 4 or 6 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: confirmCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                  counterText: '',
                ),
                validator: (v) {
                  if (v != pinCtrl.text) return 'PINs do not match';
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx);
                      setState(() => _pinLockEnabled = true);
                      _showSnackBar(
                        'PIN lock set successfully',
                        color: Colors.green,
                      );
                    }
                  },
                  child: const Text('Set PIN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
            SizedBox(width: 8.w),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is permanent and cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            ),
            SizedBox(height: 12.h),
            const Text('Deleting your account will:'),
            SizedBox(height: 8.h),
            _buildBullet('Remove all your personal data'),
            _buildBullet('Delete your household records'),
            _buildBullet('Remove all your vehicles and pets'),
            _buildBullet('Cancel any pending service requests'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar(
                'Account deletion request submitted. You will receive a confirmation email.',
              );
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Active Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),
            _buildSessionItem(
              icon: Icons.phone_android,
              label: 'This Device',
              subtitle: 'Android · Active now',
              isCurrent: true,
              theme: Theme.of(ctx),
            ),
            Divider(height: 1),
            _buildSessionItem(
              icon: Icons.computer,
              label: 'Chrome · Windows',
              subtitle: 'Last active: 2 hours ago',
              isCurrent: false,
              theme: Theme.of(ctx),
              onRevoke: () {
                Navigator.pop(ctx);
                _showSnackBar('Session revoked', color: Colors.green);
              },
            ),
            SizedBox(height: 16.h),
            if (!_pinLockEnabled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showSnackBar(
                      'All other sessions revoked',
                      color: Colors.green,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: const Text('Revoke All Other Sessions'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isCurrent,
    required ThemeData theme,
    VoidCallback? onRevoke,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isCurrent ? theme.colorScheme.primary : Colors.grey,
        ),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: isCurrent
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : (onRevoke != null
                ? TextButton(
                    onPressed: onRevoke,
                    child: const Text(
                      'Revoke',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : null),
    );
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
        title: const Text('Security & Privacy'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Authentication ────────────────────────────────────────────
            _sectionHeader(theme, 'AUTHENTICATION'),
            _card(
              theme,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Change Password',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Last changed 30 days ago',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: _showChangePasswordSheet,
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.fingerprint,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Biometric Login',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Use fingerprint or face ID to unlock',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _biometricEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _biometricEnabled = v),
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.pin_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'PIN Lock',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Require PIN to open the app',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _pinLockEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) {
                    if (v) {
                      _showSetPinSheet();
                    } else {
                      setState(() => _pinLockEnabled = false);
                      _showSnackBar('PIN lock removed');
                    }
                  },
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.security,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Two-Factor Authentication',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Add extra security with OTP verification',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _twoFactorEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) {
                    setState(() => _twoFactorEnabled = v);
                    _showSnackBar('2FA ${v ? "enabled" : "disabled"}');
                  },
                ),
              ],
            ),

            // ── Sessions ─────────────────────────────────────────────────
            _sectionHeader(theme, 'SESSIONS'),
            _card(
              theme,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.devices_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Active Sessions',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    '2 devices currently logged in',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: _showActiveSessions,
                ),
              ],
            ),

            // ── Privacy ──────────────────────────────────────────────────
            _sectionHeader(theme, 'PRIVACY'),
            _card(
              theme,
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.wifi_protected_setup,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Show Online Status',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Others can see when you are online',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _showOnlineStatus,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _showOnlineStatus = v),
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Profile Visibility',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Allow society members to view your profile',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _profileVisible,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _profileVisible = v),
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Activity Visibility',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Show your activity in community feed',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _activityVisible,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (v) => setState(() => _activityVisible = v),
                ),
              ],
            ),

            // ── Data ─────────────────────────────────────────────────────
            _sectionHeader(theme, 'DATA & ACCOUNT'),
            _card(
              theme,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.download_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'Download My Data',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Request a copy of your personal data',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => _showSnackBar(
                    'Data export request submitted. You will receive an email shortly.',
                  ),
                ),
                Divider(
                  height: 0,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    'Permanently delete your account and data',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.red),
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 20.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _card(ThemeData theme, {required List<Widget> children}) {
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
}
