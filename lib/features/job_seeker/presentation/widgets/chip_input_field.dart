import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/kervia_l10n.dart';
import '../../../../core/theme/app_colors.dart';

class ChipInputField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> initialChips;
  final Function(List<String>) onChanged;
  final String? buttonLabel;
  final List<String>? suggestions;
  final String? suggestionsTitle;

  const ChipInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.initialChips,
    required this.onChanged,
    this.buttonLabel,
    this.suggestions,
    this.suggestionsTitle,
  });

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  late List<String> _chips;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chips = List.from(widget.initialChips);
  }

  void _addChip() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_chips.contains(text)) {
      setState(() {
        _chips.add(text);
      });
      widget.onChanged(_chips);
      _controller.clear();
    }
  }

  void _removeChip(String chip) {
    setState(() {
      _chips.remove(chip);
    });
    widget.onChanged(_chips);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.adaptive();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.suggestions != null && widget.suggestions!.isNotEmpty) ...[
          if (widget.suggestionsTitle != null) ...[
            Text(
              widget.suggestionsTitle!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.suggestions!.map((suggestion) {
              final added = _chips.contains(suggestion);
              return ActionChip(
                label: Text(
                  suggestion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: added ? Colors.white : AppColors.primary,
                  ),
                ),
                backgroundColor: added ? AppColors.primary : AppColors.primarySoft,
                side: BorderSide(
                  color: added ? AppColors.primary : AppColors.border,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    if (added) {
                      _chips.remove(suggestion);
                    } else {
                      _chips.add(suggestion);
                    }
                  });
                  widget.onChanged(_chips);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _addChip(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                  hintText: context.tr(widget.hint),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            if (widget.buttonLabel != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _addChip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: const Size(64, 48),
                  ),
                  child: Text(widget.buttonLabel!),
                ),
              ),
            ],
          ],
        ),
        if (_chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _chips.map((chip) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        chip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeChip(chip),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
