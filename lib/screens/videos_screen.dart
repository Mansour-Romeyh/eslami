import 'package:eslami/screens/Theme%20controller.dart';
import 'package:eslami/widgets/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  bool _isLoading = false;

  static const List<String> videoUrls = [
    "https://youtu.be/a9pZm2SKabc",
    "https://youtu.be/llWyciLv8t0",
    "https://youtu.be/rpFUGDKB8h0",
    "https://youtu.be/YrdE5c6xOdA",
    "https://youtu.be/cRFAp_EnEBg",
    "https://youtu.be/F3o8dZgeTkc",
    "https://youtu.be/IbJ93HsqJqk",
    "https://youtu.be/XBqEdEnX0z4",
    "https://youtu.be/tRam05yd6e8",
    "https://youtu.be/tTfgaCW5awc",
    "https://youtu.be/TxJscCmSZqQ",
    "https://youtu.be/Yn_7s9IGvP8",
    "https://youtu.be/oQhHLLC4ROk",
    "https://youtu.be/aW6SA6kgV_Q",
    "https://youtu.be/zOfmhtFF0lk",
    "https://youtu.be/OYEs1d9-PyA",
    "https://youtu.be/2U-_tjUHIuE",
    "https://youtu.be/JjrZP95Km8k",
    "https://youtu.be/igaoKJi2VRg",
    "https://youtu.be/RQn60LefTGM",
    "https://youtu.be/Gp7Z4CSXpZU",
    "https://youtu.be/oFgNZJbIut8",
    "https://youtu.be/hlkHK9nDVhI",
    "https://youtu.be/-lFDxvZkZig",
    "https://youtu.be/fUw0xeYL8Gg",
    "https://youtu.be/Y_NZ-ePBi3o",
    "https://youtu.be/VXaVN2kzLwI",
    "https://youtu.be/3VL6rZbWy-4",
    "https://youtu.be/BvKLGtIExYY",
    "https://youtu.be/KKJmyg-XuhE",
    "https://youtu.be/ZKWlhTcHqXU",
    "https://youtu.be/dyd-7yuRNMU",
    "https://youtu.be/ZxWP7Nhjsd8",
    "https://youtu.be/q54TtoO4MmE",
    "https://youtu.be/YVxRJ57mYsU",
    "https://youtu.be/1Vds6J6ZbWg",
    "https://youtu.be/dC6FY9xQBxg",
    "https://youtu.be/ITYUuXeY0QE",
    "https://youtu.be/AfxwZXkyxZM",
    "https://youtu.be/DNB7cvzvvBo",
    "https://youtu.be/G8CPfjznwqw",
    "https://youtu.be/d5Oir6EbZz0",
    "https://youtu.be/ghvwG4ldtn8",
    "https://youtu.be/Q9tso4sbLJE",
    "https://youtu.be/4EUGTNusTEs",
    "https://youtu.be/twfKQnY68xc",
    "https://youtu.be/W2ZpwtQgysQ",
    "https://youtu.be/HZuuygiiVSE",
    "https://youtu.be/bmj0dIkTkBs",
    "https://youtu.be/0PFIloZlep0",
    "https://youtu.be/BJD4stoqCJs",
    "https://youtu.be/bJIE5OaaicE",
    "https://youtu.be/81PJkXLkEGc",
    "https://youtu.be/O2BIUR8EmIs",
    "https://youtu.be/EdextgCQnBg",
    "https://youtu.be/zJ9kgtJAy30",
    "https://youtu.be/3dXLTSMgcXM",
    "https://youtu.be/qa_Ec2isj9w",
    "https://youtu.be/h_TsDFjC7i4",
    "https://youtu.be/d4VRRtb6NKM",
    "https://youtu.be/Iv7Jb3dFAEE",
  ];

  Future<void> _navigateToPlayer(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'لا يمكن فتح الرابط', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ أثناء حاولة فتح الفيديو', isError: true);
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.shade600
            : const Color(0xFFAC844D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeController.isDarkMode.value
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [
                    const Color(0xFF8BA09E),
                    const Color(0xFFA8B5A8),
                    const Color(0xFFCFC09E),
                    const Color(0xFFF3E5BB),
                  ],
            stops: themeController.isDarkMode.value
                ? [0.0, 1.0]
                : [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _isLoading
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerItem(responsive),
                      childCount: 6,
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      MediaQuery.of(context).padding.top + 5,
                      responsive.horizontalPadding,
                      100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return FadeInUp(
                          duration: Duration(
                            milliseconds: 300 + (index * 30).clamp(0, 300),
                          ),
                          child: _buildVideoCard(context, index, responsive),
                        );
                      }, childCount: videoUrls.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context,
    int index,
    ResponsiveHelper responsive,
  ) {
    final iconContainerSize = responsive.responsive<double>(
      small: 44,
      medium: 50,
      large: 56,
    );
    final playIconSize = responsive.iconSizeMedium;
    final badgeSize = responsive.responsive<double>(
      small: 40,
      medium: 46,
      large: 52,
    );
    final numberFontSize = responsive.responsive<double>(
      small: 18,
      medium: 22,
      large: 26,
    );

    final themeController = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(bottom: responsive.cardMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.mediumRadius + 4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeController.isDarkMode.value
              ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
              : [
                  Colors.white.withOpacity(0.75),
                  const Color(0xFFF3E5BB).withOpacity(0.85),
                ],
        ),
        border: Border.all(
          color: themeController.isDarkMode.value
              ? Colors.white12
              : const Color(0xFFAC844D).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (themeController.isDarkMode.value
                        ? Colors.black
                        : const Color(0xFFAC844D))
                    .withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(responsive.mediumRadius + 4),
          onTap: () => _navigateToPlayer(context, videoUrls[index]),
          splashColor: const Color(0xFFAC844D).withOpacity(0.1),
          highlightColor: const Color(0xFFAC844D).withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.cardPadding,
              vertical: responsive.cardPadding - 2,
            ),
            child: Row(
              children: [
                _buildPlayButton(iconContainerSize, playIconSize),
                SizedBox(width: responsive.horizontalPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFAC844D).withOpacity(0.08),
                              const Color(0xFFCFC09E).withOpacity(0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            responsive.smallRadius,
                          ),
                        ),
                        child: Text(
                          'مختصر منهاج القاصدين',
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkMode.value
                                ? Colors.white70
                                : const Color(0xFF4A5046),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildSmallBadge(
                            'صوتي',
                            Icons.headphones_rounded,
                            const Color(0xFF8BA09E),
                            responsive,
                          ),
                          const SizedBox(width: 6),
                          _buildSmallBadge(
                            'YouTube',
                            Icons.play_circle_fill,
                            Colors.red.shade400,
                            responsive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsive.horizontalPadding),
                _buildEpisodeBadge(
                  index,
                  badgeSize,
                  numberFontSize,
                  responsive,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(double size, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAC844D), Color(0xFFD4A76A)],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAC844D).withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildEpisodeBadge(
    int index,
    double size,
    double fontSize,
    ResponsiveHelper responsive,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAC844D), Color(0xFFCFC09E)],
        ),
        borderRadius: BorderRadius.circular(responsive.smallRadius + 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            'حلقة',
            style: TextStyle(
              fontSize: responsive.captionFontSize - 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              height: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(
    String label,
    IconData icon,
    Color color,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(responsive.smallRadius - 2),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.captionFontSize,
              color: color.withOpacity(0.85),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            icon,
            size: responsive.captionFontSize + 2,
            color: color.withOpacity(0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: 6,
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFCFC09E).withOpacity(0.35),
        highlightColor: const Color(0xFFF3E5BB).withOpacity(0.6),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.mediumRadius),
          ),
        ),
      ),
    );
  }
}
