import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/debouncer.dart';

class TrackSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const TrackSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<TrackSearchBar> createState() => _TrackSearchBarState();
}

class _TrackSearchBarState extends State<TrackSearchBar> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debouncer.run(() {
      widget.onSearch(value);
    });
  }

  void _onClear() {
    _controller.clear();
    _debouncer.cancel();
    widget.onClear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Search tracks or artists...',
          hintStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.grey),
                      onPressed: _onClear,
                    )
                  : const SizedBox.shrink();
            },
          ),
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSearch,
      ),
    );
  }
}
