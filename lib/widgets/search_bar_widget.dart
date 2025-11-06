import 'package:flutter/material.dart';
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  void _onClear() {
    widget.controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        autofocus: false,
        style: TextStyle(color: textColor),
        cursorColor: textColor,
        decoration: InputDecoration(
          hintText: 'Search by username, name, or occupation...',
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(Icons.search, color: iconColor),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel, color: iconColor),
                  onPressed: _onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

