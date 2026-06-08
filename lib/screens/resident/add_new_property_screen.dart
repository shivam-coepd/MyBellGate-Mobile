import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddNewPropertyScreen extends StatefulWidget {
  const AddNewPropertyScreen({super.key});

  @override
  State<AddNewPropertyScreen> createState() => _AddNewPropertyScreenState();
}

class _AddNewPropertyScreenState extends State<AddNewPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _societyCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  String _ownershipType = 'owner';
  String _propertyType = 'apartment';
  String _parkingType = 'covered';
  bool _isSubmitting = false;
  int _currentStep = 0;

  void _showSnackBar(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: bg,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSubmitting = false);
      _showSnackBar('Property added successfully! Awaiting admin verification.', bg: Colors.green);
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _societyCtrl.dispose();
    _buildingCtrl.dispose();
    _flatCtrl.dispose();
    _floorCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
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
        title: const Text('Add New Property'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step Indicator ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _stepCircle(theme, 1, 'Society', _currentStep >= 0),
                    _stepLine(theme, _currentStep >= 1),
                    _stepCircle(theme, 2, 'Property', _currentStep >= 1),
                    _stepLine(theme, _currentStep >= 2),
                    _stepCircle(theme, 3, 'Details', _currentStep >= 2),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ── Section 1: Society ──────────────────────────────────────
              _sectionTitle(theme, Icons.business_outlined, 'Society Details'),
              SizedBox(height: 12.h),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _societyCtrl,
                        decoration: InputDecoration(
                          labelText: 'Society Name / Code',
                          hintText: 'Enter society name or registration code',
                          prefixIcon: Icon(Icons.apartment, color: theme.colorScheme.primary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter society name' : null,
                        onChanged: (_) => _updateStep(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ── Section 2: Property ─────────────────────────────────────
              _sectionTitle(theme, Icons.home_outlined, 'Property Details'),
              SizedBox(height: 12.h),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      // Property type
                      Text('Property Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          for (final pt in ['apartment', 'villa', 'row house', 'plot'])
                            ChoiceChip(
                              label: Text(pt[0].toUpperCase() + pt.substring(1)),
                              selected: _propertyType == pt,
                              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                              onSelected: (v) {
                                if (v) setState(() => _propertyType = pt);
                                _updateStep();
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      TextFormField(
                        controller: _buildingCtrl,
                        decoration: InputDecoration(
                          labelText: 'Building / Wing Name',
                          hintText: 'e.g. A-Wing, Block B',
                          prefixIcon: Icon(Icons.apartment_outlined, color: theme.colorScheme.primary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        onChanged: (_) => _updateStep(),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: _flatCtrl,
                        decoration: InputDecoration(
                          labelText: 'Flat / House Number',
                          hintText: 'e.g. 101, B-202',
                          prefixIcon: Icon(Icons.door_front_door_outlined, color: theme.colorScheme.primary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        onChanged: (_) => _updateStep(),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _floorCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Floor',
                                hintText: 'e.g. 3',
                                prefixIcon: Icon(Icons.layers_outlined, color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _areaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Area (sq.ft)',
                                hintText: 'e.g. 1200',
                                prefixIcon: Icon(Icons.square_foot_outlined, color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ── Section 3: Additional Details ───────────────────────────
              _sectionTitle(theme, Icons.info_outline, 'Additional Details'),
              SizedBox(height: 12.h),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ownership Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          for (final ot in ['owner', 'tenant', 'family'])
                            ChoiceChip(
                              label: Text(ot[0].toUpperCase() + ot.substring(1)),
                              selected: _ownershipType == ot,
                              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                              onSelected: (v) {
                                if (v) setState(() => _ownershipType = ot);
                                _updateStep();
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text('Parking Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          for (final pk in ['covered', 'open', 'none'])
                            ChoiceChip(
                              label: Text(pk[0].toUpperCase() + pk.substring(1)),
                              selected: _parkingType == pk,
                              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                              onSelected: (v) => v ? setState(() => _parkingType = pk) : null,
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.orange[700]),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Your property request will be verified by the society admin. You will receive a notification once approved.',
                                style: TextStyle(fontSize: 12, color: Colors.orange[800], height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ── Submit Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add_home_outlined, size: 20),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Add Property', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStep() {
    int step = 0;
    if (_societyCtrl.text.isNotEmpty) step = 1;
    if (_buildingCtrl.text.isNotEmpty && _flatCtrl.text.isNotEmpty) step = 2;
    if (step != _currentStep) setState(() => _currentStep = step);
  }

  Widget _stepCircle(ThemeData theme, int num, String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32.w, height: 32.w,
            decoration: BoxDecoration(
              color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: active
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('$num', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
            ),
          ),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
              color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _stepLine(ThemeData theme, bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 20.h),
        color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        SizedBox(width: 10.w),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
