import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupVisitorEntryScreen extends StatefulWidget {
  const GroupVisitorEntryScreen({super.key});

  @override
  State<GroupVisitorEntryScreen> createState() => _GroupVisitorEntryScreenState();
}

class _GroupVisitorEntryScreenState extends State<GroupVisitorEntryScreen> {
  final List<Map<String, dynamic>> _groupVisitors = [
    {
      'id': 1,
      'name': 'Rahul Kumar',
      'type': 'Contractor',
      'flat': 'A-101',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'type': 'Laborer',
      'flat': 'A-101',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _purposeController = TextEditingController();
  String _selectedType = 'Contractor';

  final List<String> _visitorTypes = [
    'Contractor',
    'Laborer',
    'Delivery',
    'Service',
    'Other',
  ];

  void _addVisitor() {
    if (_nameController.text.isNotEmpty && _flatController.text.isNotEmpty) {
      setState(() {
        _groupVisitors.add({
          'id': _groupVisitors.length + 1,
          'name': _nameController.text,
          'type': _selectedType,
          'flat': _flatController.text,
          'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
        });
      });
      _nameController.clear();
      _flatController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visitor added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _removeVisitor(int id) {
    setState(() {
      _groupVisitors.removeWhere((visitor) => visitor['id'] == id);
    });
  }

  void _submitGroupEntry() {
    if (_groupVisitors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group entry submitted successfully!'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Group Visitor Entry'),
              actions: [
                IconButton(
                  onPressed: _submitGroupEntry,
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Entry Details Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Entry Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _flatController,
                            decoration: const InputDecoration(
                              labelText: 'Flat Number',
                              hintText: 'Enter flat number',
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _purposeController,
                            decoration: const InputDecoration(
                              labelText: 'Purpose of Visit',
                              hintText: 'Enter purpose of visit',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Visitor Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: _visitorTypes
                                .map(
                                  (type) => ChoiceChip(
                                    label: Text(type),
                                    selected: _selectedType == type,
                                    selectedColor: AppTheme.primary,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _selectedType = selected ? type : _selectedType;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add Visitor Form
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Visitor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Visitor Name',
                              hintText: 'Enter visitor name',
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: _addVisitor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              minimumSize: Size(double.infinity, 50.h),
                            ),
                            child: const Text(
                              'Add Visitor',
                              style: TextStyle(color: AppTheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Visitors List
                  const Text(
                    'Group Visitors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_groupVisitors.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No visitors added yet. Add visitors to the group.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.onBackgroundLight,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _groupVisitors.length,
                      itemBuilder: (context, index) {
                        final visitor = _groupVisitors[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(visitor['image']),
                                ),
                                SizedBox(width: 15.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        visitor['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        '${visitor['type']} • ${visitor['flat']}',
                                        style: const TextStyle(
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeVisitor(visitor['id']),
                                  icon: const Icon(Icons.delete, color: AppTheme.error),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}