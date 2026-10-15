import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class DailyHelperQrPassScreen extends StatefulWidget {
  final Map<String, dynamic> helper;

  const DailyHelperQrPassScreen({super.key, required this.helper});

  @override
  State<DailyHelperQrPassScreen> createState() =>
      _DailyHelperQrPassScreenState();
}

class _DailyHelperQrPassScreenState extends State<DailyHelperQrPassScreen> {
  final HouseholdRepository _repository = HouseholdRepository();
  final GlobalKey _passCardKey = GlobalKey();
  List<Map<String, dynamic>> _logs = [];
  bool _loadingLogs = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final id = int.tryParse(widget.helper['id']?.toString() ?? '') ?? 0;
    if (id == 0) {
      setState(() => _loadingLogs = false);
      return;
    }
    try {
      final logs = await _repository.getDailyHelperLogs(dailyHelperId: id);
      if (mounted) {
        setState(() {
          _logs = logs;
          _loadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingLogs = false);
    }
  }

  Future<void> _shareQrPass() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    final qrCode = widget.helper['qr_code'] ?? '';
    final name = widget.helper['name'] ?? 'Daily Helper';
    final service = widget.helper['service_type'] ?? 'Service';
    final shareText =
        'Gate Pass for $name ($service)\nQR Code: $qrCode\nShow this QR code image to Gate Guard for instant entry and exit registration.';

    try {
      // Capture the visual Pass Card (including the QR code) as an image
      final boundary =
          _passCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/gate_pass_$qrCode.png');
          await file.writeAsBytes(pngBytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareText,
            subject: 'MyGateBell Gate Pass - $name',
          );
          if (mounted) setState(() => _isSharing = false);
          return;
        }
      }

      // Fallback if boundary capture is not ready
      await Share.share(shareText, subject: 'MyGateBell Gate Pass - $name');
    } catch (e) {
      await Share.share(shareText, subject: 'MyGateBell Gate Pass - $name');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    log("Widget Helper data : ${widget.helper}");
    final theme = Theme.of(context);
    final name = widget.helper['name'] ?? 'Helper';
    final phone = widget.helper['phone'] ?? '';
    final imageUrl = widget.helper['image_url'] ?? '';
    final serviceType = widget.helper['service_type'] ?? 'Service';
    final qrCode = widget.helper['qr_code'] ?? 'DHP-${widget.helper['id']}';
    final flatNumber = widget.helper['flat_number'] ?? '';
    final buildingName = widget.helper['building_name'] ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Permanent Gate Pass'),
        actions: [
          IconButton(
            onPressed: _shareQrPass,
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share QR Pass',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PASS CARD (Wrapped in RepaintBoundary to capture as image for sharing)
            RepaintBoundary(
              key: _passCardKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Pass Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22.r),
                          topRight: Radius.circular(22.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: theme.primaryColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'MYGATEBELL PASS',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'PERMANENT',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Helper Details
                    CircleAvatar(
                      radius: 36.r,
                      backgroundColor: theme.primaryColor.withOpacity(0.15),
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(200.r),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'H',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        serviceType,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),

                    if (phone.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    if (flatNumber.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Flat: ${buildingName.isNotEmpty ? "$buildingName - " : ""}$flatNumber',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h),

                    // QR Code Box
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: QrImageView(
                        data: qrCode,
                        version: QrVersions.auto,
                        size: 190.r,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        qrCode,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'Guard will scan this QR at gate to mark both Entry and Exit.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // SHARE BUTTON
            ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareQrPass,
              icon: _isSharing
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share),
              label: Text(
                _isSharing
                    ? 'Generating Pass Image...'
                    : 'Share Gate Pass with Helper',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ENTRY / EXIT ATTENDANCE LOGS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Entry / Exit Logs',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _fetchLogs,
                  icon: const Icon(Icons.refresh),
                  iconSize: 20.sp,
                ),
              ],
            ),

            SizedBox(height: 10.h),

            if (_loadingLogs)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_logs.isEmpty)
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 36.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No entry/exit logs recorded yet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _logs.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  final entryStr = log['entry_time']?.toString() ?? '';
                  final exitStr = log['exit_time']?.toString() ?? '';
                  final isInside = log['status'] == 'inside';

                  String formattedEntry = entryStr;
                  try {
                    final dt = DateTime.parse(entryStr);
                    formattedEntry = DateFormat('dd MMM, hh:mm a').format(dt);
                  } catch (_) {}

                  String formattedExit = 'Inside Now';
                  if (exitStr.isNotEmpty) {
                    try {
                      final dt = DateTime.parse(exitStr);
                      formattedExit = DateFormat('dd MMM, hh:mm a').format(dt);
                    } catch (_) {}
                  }

                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isInside
                            ? Colors.green.withOpacity(0.4)
                            : isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: isInside
                                ? Colors.green.withOpacity(0.12)
                                : isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInside ? Icons.login : Icons.logout,
                            color: isInside ? Colors.green.shade700 : null,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isInside
                                        ? 'Currently Inside'
                                        : 'Visit Completed',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isInside
                                          ? Colors.green.shade700
                                          : null,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isInside
                                          ? Colors.green.withOpacity(0.15)
                                          : isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Text(
                                      isInside ? 'Active' : 'Exited',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isInside
                                            ? Colors.green.shade700
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'In: $formattedEntry',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (!isInside)
                                Text(
                                  'Out: $formattedExit',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
