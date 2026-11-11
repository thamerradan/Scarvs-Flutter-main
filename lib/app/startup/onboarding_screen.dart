// يعرض خطوات التعريف الأولي ويتيح الانتقال إلى التطبيق.
import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:scarvs/app/constants/app_assets.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/app/router/app_router.dart';
import 'package:scarvs/app/startup/onboarding_widget.dart';
import 'package:scarvs/app/startup/onboarding_model.dart';

class OnBoardingScreen extends StatefulWidget {
  OnBoardingScreen({Key? key}) : super(key: key);

  final List<OnBoardingModel> cards = [
    OnBoardingModel(
      image: AppAssets.onBoardingOne,
      title: 'أرقى وأحدث تشكيلات الأحذية العصرية بين يديك',
      textColor: Colors.white,
      bgColor: AppColors.mirage,
    ),
    OnBoardingModel(
      image: AppAssets.onBoardingTwo,
      title: 'خدمة عملاء وتوصيل سريع وموثوق حتى باب منزلك',
      bgColor: AppColors.creamColor,
      textColor: AppColors.mirage,
    ),
    OnBoardingModel(
      image: AppAssets.onBoardingThree,
      title: 'عروض حصرية ووسائل دفع متعددة ومرنة تناسبك',
      bgColor: AppColors.rawSienna,
      textColor: Colors.white,
    ),
  ];

  List<Color> get colors => cards.map((p) => p.bgColor).toList();

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        colors: widget.colors,
        radius: 30,
        itemCount: 3,
        curve: Curves.ease,
        duration: const Duration(seconds: 2),
        itemBuilder: (index) {
          OnBoardingModel card = widget.cards[index % widget.cards.length];
          return PageCard(card: card);
        },
        onFinish: () {
          Navigator.of(context).pushReplacementNamed(AppRouter.splashRoute);
        },
      ),
    );
  }
}
