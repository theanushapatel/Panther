import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? titleColor;
  final VoidCallback? onLeadingPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 2,
    this.backgroundColor,
    this.titleColor,
    this.onLeadingPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.primary,
      leading: leading ?? _buildDefaultLeading(context),
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  Widget? _buildDefaultLeading(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
        color: titleColor ?? AppColors.textPrimary,
      );
    }
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// App bar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String) onSearch;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;

  const SearchAppBar({
    Key? key,
    required this.title,
    required this.onSearch,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
  }) : super(key: key);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        widget.onSearch('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: widget.titleColor?.withOpacity(0.6) ?? 
                         AppColors.textPrimary.withOpacity(0.6),
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: widget.titleColor ?? AppColors.textPrimary,
              ),
              onChanged: widget.onSearch,
            )
          : Text(
              widget.title,
              style: TextStyle(
                color: widget.titleColor ?? AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
      centerTitle: widget.centerTitle,
      backgroundColor: widget.backgroundColor ?? AppColors.primary,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
          color: widget.titleColor ?? AppColors.textPrimary,
        ),
        if (!_isSearching && widget.actions != null) ...widget.actions!,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }
}

// App bar with refresh functionality
class RefreshAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onRefresh;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool isRefreshing;

  const RefreshAppBar({
    Key? key,
    required this.title,
    required this.onRefresh,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.isRefreshing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primary,
      actions: [
        IconButton(
          icon: isRefreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                  ),
                )
              : const Icon(Icons.refresh),
          onPressed: isRefreshing ? null : onRefresh,
          color: titleColor ?? AppColors.textPrimary,
        ),
        if (actions != null) ...actions!,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}