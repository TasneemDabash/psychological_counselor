import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class ChatTextField extends StatelessWidget {
  const ChatTextField({
    super.key,
    required TextEditingController controller,
    required this.context,
  }) : _controller = controller;

  final TextEditingController _controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.black, // Background color for the text field
        borderRadius: BorderRadius.circular(30.r), // Rounded corners
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.white),
          cursorColor: AppColors.background,
          decoration: InputDecoration(
            hintText: "Type your message...",
            hintStyle: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColors.background),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ), // Adjust padding for better height alignment
          ),
        ),
      ),
    );
  }
}
