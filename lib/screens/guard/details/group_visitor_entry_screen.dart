import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class GroupVisitorEntryScreen extends StatefulWidget {
  const GroupVisitorEntryScreen({super.key});

  @override
  State<GroupVisitorEntryScreen> createState() =>
      _GroupVisitorEntryScreenState();
}

class _GroupVisitorEntryScreenState extends State<GroupVisitorEntryScreen> {
  final _purposeCtrl = TextEditingController();
  final _residentIdCtrl = TextEditingController();
  final _purposeFormKey = GlobalKey<FormState>();
  String _visitorType = 'other';

  // Each entry: {name, phone}
  final List<Map<String, dynamic>> _members = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _residentIdCtrl.dispose();
    super.dispose();
  }

  void _showAddMemberSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final key = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
        ),
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Group Member',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Name *', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                    labelText: 'Phone *', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().length < 10) ? 'Enter valid phone' : null,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (key.currentState!.validate()) {
                      setState(() {
                        _members.add({
                          'name': nameCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child:
                      const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitGroup() async {
    if (!_purposeFormKey.currentState!.validate()) return;
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one group member'),
            backgroundColor: AppTheme.warning),
      );
      return;
    }

    final residentId = int.tryParse(_residentIdCtrl.text.trim());
    if (residentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid Resident ID'),
            backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    int successCount = 0;
    int failCount = 0;

    for (final member in _members) {
      try {
        if (!mounted) break;
        context.read<GuardBloc>().add(AddVisitor(
              name: member['name'],
              phone: member['phone'],
              purpose: _purposeCtrl.text.trim(),
              visitorType: _visitorType,
              residentId: residentId,
            ));

        final result = await context.read<GuardBloc>().stream
            .firstWhere((s) => s is VisitorAdded || s is GuardError)
            .timeout(const Duration(seconds: 15));

        if (result is VisitorAdded) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (_) {
        failCount++;
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(failCount == 0
          ? '$successCount member(s) added successfully'
          : '$successCount added, $failCount failed'),
      backgroundColor: failCount == 0 ? AppTheme.success : AppTheme.warning,
    ));

    if (successCount > 0) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Visitor Entry'),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submitGroup,
            icon: _isSubmitting
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary))
                : const Icon(Icons.check, color: AppTheme.primary),
            label: Text('Submit',
                style: TextStyle(color: AppTheme.primary, fontSize: 14.sp)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry details form
            Form(
              key: _purposeFormKey,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entry Details',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _purposeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Purpose of Visit *',
                            border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: _residentIdCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Resident ID *',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        initialValue: _visitorType,
                        decoration: const InputDecoration(
                            labelText: 'Visitor Type',
                            border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: 'other', child: Text('Group / Other')),
                          DropdownMenuItem(
                              value: 'service', child: Text('Service Workers')),
                          DropdownMenuItem(
                              value: 'guest', child: Text('Guests')),
                        ],
                        onChanged: (v) =>
                            setState(() => _visitorType = v ?? 'other'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Members section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Group Members (${_members.length})',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _showAddMemberSheet,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Add',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h)),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            if (_members.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.group_add_outlined,
                            size: 48.sp, color: Colors.grey),
                        SizedBox(height: 8.h),
                        Text('No members added yet',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                itemBuilder: (_, i) {
                  final m = _members[i];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp),
                        ),
                      ),
                      title: Text(m['name'],
                          style:
                              TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                      subtitle: Text(m['phone'],
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.onBackgroundLight)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppTheme.error),
                        onPressed: () =>
                            setState(() => _members.removeAt(i)),
                      ),
                    ),
                  );
                },
              ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            minimumSize: Size(double.infinity, 52.h),
          ),
          icon: _isSubmitting
              ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.how_to_reg, color: Colors.white),
          label: Text(
            _isSubmitting ? 'Submitting...' : 'Submit Group Entry',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
