import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable search field widget with autocomplete functionality
class SearchField extends StatefulWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final List<String>? suggestions;
  final Function(String)? onSuggestionSelected;
  final bool showClearButton;

  const SearchField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.suggestions,
    this.onSuggestionSelected,
    this.showClearButton = true,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.suggestions != null && _controller.text.isNotEmpty) {
      final query = _controller.text.toLowerCase();
      setState(() {
        _filteredSuggestions = widget.suggestions!
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query) &&
                suggestion.toLowerCase() != query.toLowerCase())
            .take(5)
            .toList();
        _showSuggestions = _filteredSuggestions.isNotEmpty;
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    setState(() {
      _showSuggestions = false;
    });
    widget.onChanged?.call('');
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSuggestionSelected?.call(suggestion);
    widget.onChanged?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search...',
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: widget.showClearButton &&
                    _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearText,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          onChanged: (value) {
            // Handled by controller listener
          },
          onSubmitted: widget.onSubmitted,
        ),
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  dense: true,
                  onTap: () => _selectSuggestion(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}

