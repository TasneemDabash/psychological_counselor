import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoWithText extends StatelessWidget {
  const LogoWithText({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        children: [
          Image.asset(
            "assets/images/AppLogo.png",
            height: 22.h,
            // Replace with actual avatar image URL
          ),
          SizedBox(
            width: 5.w,
          ),
          Text('Psychiatric AI Bot',style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.sp),)
        ],
      ),
    );
  }
}
