import 'package:flutter/material.dart';
import '../../core/constants/app_decorations.dart';
import '../../core/extensions/theme_extension.dart';
import 'tap_scale.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: AppDecorations.cardDecoration(context),
          child: Icon(
            Icons.chevron_left,
            size: 22,
            color: context.onSurface,
          ),
        ),
      ),
    );
  }
}
