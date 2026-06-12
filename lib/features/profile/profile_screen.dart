import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/gradient_button.dart';

/// Screen 09 — Profile. Personal, medical, and emergency-contact info. The
/// Save button enables only when something changed. (Local only for now;
/// persistence lands in a later round.)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Seed values (would come from storage).
  final _initial = <String, String>{
    'name': 'Margaret',
    'age': '68',
    'meds': 'Levodopa, Carbidopa',
    'clinician': 'Dr. Alvarez',
    'contactType': 'Daughter',
    'contactName': 'Sarah',
    'contactPhone': '+1 555 0142',
  };

  late final Map<String, TextEditingController> _c = {
    for (final e in _initial.entries) e.key: TextEditingController(text: e.value)
  };

  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    for (final ctrl in _c.values) {
      ctrl.addListener(_recomputeDirty);
    }
  }

  void _recomputeDirty() {
    final dirty = _c.entries.any((e) => e.value.text != _initial[e.key]);
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  void _save() {
    for (final e in _c.entries) {
      _initial[e.key] = e.value.text;
    }
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved')),
    );
  }

  @override
  void dispose() {
    for (final ctrl in _c.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
          AppSpacing.lg, AppSpacing.navClearance),
      children: [
        Text(l10n?.profile ?? 'Profile', style: AppType.h1),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: l10n?.personalInfo ?? 'Personal information',
          icon: Icons.person_rounded,
          children: [
            _Field(
                label: l10n?.fieldName ?? 'Name', controller: _c['name']!),
            _Field(
                label: l10n?.fieldAge ?? 'Age',
                controller: _c['age']!,
                number: true),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: l10n?.medicalInfo ?? 'Medical information',
          icon: Icons.local_hospital_rounded,
          children: [
            _Field(
                label: l10n?.fieldMeds ?? 'Medications',
                controller: _c['meds']!),
            _Field(
                label: l10n?.fieldClinician ?? 'Assigned clinician',
                controller: _c['clinician']!),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: l10n?.emergencyContact ?? 'Emergency contact',
          icon: Icons.phone_android_rounded,
          children: [
            _Field(
                label: l10n?.fieldRelationship ?? 'Relationship',
                controller: _c['contactType']!),
            _Field(
                label: l10n?.fieldName ?? 'Name',
                controller: _c['contactName']!),
            _Field(
                label: l10n?.fieldPhone ?? 'Phone',
                controller: _c['contactPhone']!,
                number: true),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        GradientButton(
          label: l10n?.saveChanges ?? 'Save changes',
          icon: Icons.check_rounded,
          onPressed: _dirty ? _save : null,
          gradient: AppColors.pinkGradient,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.children, this.icon});
  final String title;
  final List<Widget> children;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppType.label),
              if (icon != null)
                Icon(icon, size: 20, color: AppColors.inkFaint),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.label, required this.controller, this.number = false});
  final String label;
  final TextEditingController controller;
  final bool number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppType.label.copyWith(color: AppColors.inkSoft)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: number ? TextInputType.text : TextInputType.text,
            style: AppType.h2.copyWith(fontSize: 18),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.field,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
