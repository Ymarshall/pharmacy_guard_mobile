import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/theme_extension.dart';
import 'nav_back_button.dart';

class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScreenAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: showBack ? AppSpacing.md : AppSpacing.lg,
      leadingWidth: showBack ? 56 : null,
      automaticallyImplyLeading: false,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: NavBackButton(onTap: onBack),
            )
          : null,
      title: title == null ? null : Text(title!),
      actions: actions,
    );
  }
}
