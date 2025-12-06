import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tcm_return_pilot/constants/app_colors.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';

class CustomLoadingButton extends StatelessWidget {
  final String text;

  const CustomLoadingButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[300],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
            const SizedBox(width: 16),
            Text(text, style: poppinsMedium.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// class PrimaryLoader extends StatelessWidget {
//   final double height;
//   final double width;

//   const PrimaryLoader({super.key, this.height = 100, this.width = 100});

//   @override
//   Widget build(BuildContext context) {
//     return Lottie.asset(Strings.loadingLineAnim, width: width, height: height);
//   }
// }
