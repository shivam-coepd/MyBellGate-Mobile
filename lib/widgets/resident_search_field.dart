import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/guard_repository.dart';

class ResidentSearchField extends StatefulWidget {
  final void Function(int residentId)? onSelected;
  final String labelText;
  final FormFieldValidator<String>? validator;

  const ResidentSearchField({
    super.key,
    this.onSelected,
    this.labelText = 'Resident *',
    this.validator,
  });

  @override
  State<ResidentSearchField> createState() => _ResidentSearchFieldState();
}

class _ResidentSearchFieldState extends State<ResidentSearchField> {
  List<Map<String, dynamic>> _residents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResidents();
  }

  Future<void> _fetchResidents() async {
    try {
      final list = await context.read<GuardRepository>().getResidents(limit: 1000);
      if (mounted) {
        setState(() {
          _residents = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Loading residents...', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) =>
          '${option['name']} - ${option['flat_number'] ?? 'No flat'}',
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return _residents.take(10);
        }
        return _residents.where((resident) {
          final name = resident['name'].toString().toLowerCase();
          final flat = (resident['flat_number'] ?? '').toString().toLowerCase();
          final query = textEditingValue.text.toLowerCase();
          return name.contains(query) || flat.contains(query);
        });
      },
      onSelected: (Map<String, dynamic> selection) {
        final id = int.tryParse(selection['id'].toString());
        if (id != null && widget.onSelected != null) {
          widget.onSelected!(id);
        }
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
            hintText: 'Type flat number or name',
          ),
          validator: widget.validator ??
              (v) => (v == null || v.isEmpty) ? 'Please select a resident' : null,
          onFieldSubmitted: (v) {
            onFieldSubmitted();
          },
        );
      },
    );
  }
}
