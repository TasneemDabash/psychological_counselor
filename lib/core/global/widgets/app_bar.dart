import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class BuildAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitle;
  final String? assetPath;
  final Widget? customActionWidget;
  final Function()? onPressed;
  final bool showLeading; // New property to make leading optional
  final bool centerTitle;
  const BuildAppBar({
    super.key,
    required this.appBarTitle,
    this.assetPath,
    this.customActionWidget,
    this.onPressed,
    this.showLeading = true,  this.centerTitle=true, // Default value is true (leading icon shown)
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = 14.sp; // Adjusted icon size to be smaller
    double buttonSize = 36.w; // Reduced button size for a smaller look
    double paddingHorizontal = 10.0.w;
    double iconPadding = 8.0.w;

    // Further adjustments for very small screens
    if (ScreenUtil().screenWidth <= 360) {
      iconSize = 12.sp;
      buttonSize = 32.w;
      paddingHorizontal = 6.0.w;
      iconPadding = 6.0.w;
    }

    return AppBar(
      leadingWidth: showLeading ? (buttonSize + paddingHorizontal) : 0, // Adjust width if no leading
      backgroundColor: Colors.transparent,
      elevation: 0,

      scrolledUnderElevation: 0,
      leading: showLeading
          ? Container(
        height: buttonSize,
        width: buttonSize,
        margin: EdgeInsets.only(left: paddingHorizontal, right: iconPadding),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: iconSize),
          onPressed: onPressed,
        ),
      )
          : null, // If `showLeading` is false, leading will be null
      title: Text(
        appBarTitle,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: centerTitle,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: paddingHorizontal),
          child: customActionWidget != null
              ? customActionWidget!
              : (assetPath != null
              ? SvgPicture.asset(
            assetPath!,
            height: 20.h,
            width: 20.w,
          )
              : Container()),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
