import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// A field that opens a searchable bottom-sheet picker.
///
/// Users can tap a listed option, or type their own text (an option to
/// "Use '\<typed text\>'" appears while typing), so missing dataset entries
/// never block the flow.
class SearchableDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String hint;
  final IconData? prefixIcon;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint = 'Select an option',
    this.prefixIcon,
  });

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SearchablePickerSheet(
        options: options,
        current: value,
        hint: hint,
      ),
    );
    if (selected != null && selected != value) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final isEmpty = value.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(label),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceVariant,
              hintText: context.tr(hint),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: AppColors.textMuted)
                  : null,
              suffixIcon: Icon(
                Icons.expand_more,
                size: 20,
                color: AppColors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.borderFocused,
                  width: 1.8,
                ),
              ),
            ),
            child: Text(
              isEmpty ? context.tr(hint) : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchablePickerSheet extends StatefulWidget {
  final List<String> options;
  final String current;
  final String hint;

  const _SearchablePickerSheet({
    required this.options,
    required this.current,
    required this.hint,
  });

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  late String _query = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options.where((o) => o.toLowerCase().contains(q)).toList();
  }

  String get _trimmedQuery => _query.trim();

  void _select(String value) {
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    final filtered = _filtered;
    final canAddCustom =
        _trimmedQuery.isNotEmpty &&
        !widget.options.any((o) => o.toLowerCase() == _trimmedQuery.toLowerCase());
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
                  hintText: '${context.tr('Search')} ${context.tr(widget.hint).toLowerCase()}',
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
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (canAddCustom)
                    ListTile(
                      leading: const Icon(Icons.add, color: AppColors.primary),
                      title: Text(
                        '${context.tr('Use')} \'$_trimmedQuery\'',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () => _select(_trimmedQuery),
                    ),
                  if (filtered.isEmpty && !canAddCustom)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.tr(
                            'No matching options. Type above to add your own.'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...filtered.map(
                    (option) => ListTile(
                      title: Text(
                        option,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: option == widget.current
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: option == widget.current
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: option == widget.current
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () => _select(option),
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
}