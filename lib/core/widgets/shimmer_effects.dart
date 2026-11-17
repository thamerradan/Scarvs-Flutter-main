// يوفر تأثيرات تحميل هيكلية لعناصر الواجهة.
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// تأثيرات الوميض (Shimmer) المتجاوبة مع الاتجاه العربي وتغييرات الثيم
class ShimmerEffects {
  static const double _spaceHeight = 10;

  static Widget loadShimmer({required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
    final highlightColor =
        isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade300;

    return SizedBox(
      height: 250,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 8,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0, end: 8.0),
              child: Container(
                height: 250,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget buildCategoryShimmer({required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
    final highlightColor =
        isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade100;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 24) / 2 - 12;

    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      primary: false,
      childAspectRatio: 5 / 8,
      shrinkWrap: true,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      crossAxisCount: 2,
      children: List.generate(8, (index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
          color: isDark ? const Color(0xff1A202C) : Colors.white,
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: Container(
                    width: cardWidth,
                    height: cardWidth,
                    color: baseColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: baseColor,
                        ),
                        height: 12,
                      ),
                      const SizedBox(height: _spaceHeight),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: baseColor,
                        ),
                        height: 12,
                        width: cardWidth * 0.6,
                      ),
                      const SizedBox(height: _spaceHeight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
