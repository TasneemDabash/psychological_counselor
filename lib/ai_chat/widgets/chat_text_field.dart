import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const ChatTextField({
    Key? key,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              FocusScope.of(context).unfocus();
              onSubmitted(value);
            }
          },
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
            ),
          ),
        ),
      ),
    );
  }
}
