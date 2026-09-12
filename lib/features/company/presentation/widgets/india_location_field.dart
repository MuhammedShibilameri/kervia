import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/job_seeker/presentation/data/step2_options_data.dart';

/// A [TextFormField] that validates like a normal field but adds a search
/// action which opens a searchable picker of all Indian states and districts.
class IndiaLocationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  const IndiaLocationField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _IndiaLocationSheet(),
    );
    if (selected != null && controller.text.trim() != selected) {
      controller.text = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: IconButton(
          tooltip: context.tr('Search location'),
          icon: Icon(Icons.search, color: AppColors.primary, size: 20),
          onPressed: () => _openPicker(context),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _IndiaLocationSheet extends StatefulWidget {
  const _IndiaLocationSheet();

  @override
  State<_IndiaLocationSheet> createState() => _IndiaLocationSheetState();
}

class _IndiaLocationSheetState extends State<_IndiaLocationSheet> {
  String _query = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _matchingStates {
    final q = _query.trim().toLowerCase();
    return stateOptions
        .where((s) => s.toLowerCase().contains(q))
        .toList();
  }

  bool _districtMatches(String district, String q) =>
      district.toLowerCase().contains(q);

  void _select(String value) => Navigator.of(context).pop(value);

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final q = _query.trim().toLowerCase();
    final showSections = q.isEmpty;
    final customAllowed = q.isNotEmpty;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: context.tr('Search all Indian states and districts'),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Flexible(
              child: showSections
                  ? ListView(
                      shrinkWrap: true,
                      children: [
                        for (final state in stateOptions) ...[
                          _groupHeader(context, state),
                          ...(districtsByState[state] ?? const <String>[])
                              .map(
                                (district) => _districtTile(
                                  district,
                                  state,
                                ),
                              ),
                        ],
                      ],
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        if (customAllowed)
                          ListTile(
                            leading:
                                const Icon(Icons.add, color: AppColors.primary),
                            title: Text(
                              context.tr("Use '{value}'").replaceFirst(
                                  '{value}', _query.trim()),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: () => _select(_query.trim()),
                          ),
                        for (final state in _matchingStates)
                          _districtTile(null, state),
                        for (final entry in districtsByState.entries)
                          for (final district in entry.value)
                            if (_districtMatches(district, q))
                              _districtTile(district, entry.key),
                        if (q.isNotEmpty &&
                            _matchingStates.isEmpty &&
                            !districtsByState.values
                                .any((list) => list.any((d) =>
                                    d.toLowerCase().contains(q))))
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              context.tr(
                                  'No matching options. Type above to add your own.'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupHeader(BuildContext context, String state) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        state.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _districtTile(String? district, String state) {
    final title = district ?? state;
    final subtitle =
        district == null ? context.tr('State / Union Territory') : state;
    return ListTile(
      dense: district != null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: district == null ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
      leading: Icon(
        district == null ? Icons.location_city : Icons.place_outlined,
        size: 20,
        color: AppColors.primary,
      ),
      onTap: () => _select(district == null ? state : '$district, $state'),
    );
  }
}