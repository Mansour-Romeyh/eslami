import 'package:animate_do/animate_do.dart';
import 'package:eslami/screens/Theme%20controller.dart';
import 'package:eslami/widgets/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({Key? key}) : super(key: key);

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'أذكار الصباح',
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFFB74D),
      'content': [
        {
          'text':
              'أعوذ بالله من الشيطان الرجيم: (اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ...) [آية الكرسي]',
          'count': 1,
        },
        {
          'text':
              'بسم الله الرحمن الرحيم: (قُلْ هُوَ اللَّهُ أَحَدٌ...) والْمُعَوِّذَتَيْنِ',
          'count': 3,
        },
        {
          'text':
              'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
          'count': 3,
        },
        {
          'text':
              'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
          'count': 1,
        },
        {
          'text':
              'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
          'count': 3,
        },
        {
          'text':
              'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
          'count': 3,
        },
        {
          'text':
              'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ وَكَلِمَةِ الْإِخْلَاصِ وَدِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ',
          'count': 1,
        },
        {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'count': 100},
        {
          'text':
              'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          'count': 100,
        },
        {'text': 'أستغفر الله وأتوب إليه', 'count': 100},
      ],
    },
    {
      'title': 'أذكار المساء',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF7986CB),
      'content': [
        {
          'text':
              'أعوذ بالله من الشيطان الرجيم: (اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ...) [آية الكرسي]',
          'count': 1,
        },
        {
          'text':
              'بسم الله الرحمن الرحيم: (قُلْ هُوَ اللَّهُ أَحَدٌ...) والْمُعَوِّذَتَيْنِ',
          'count': 3,
        },
        {
          'text':
              'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...',
          'count': 1,
        },
        {
          'text':
              'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
          'count': 3,
        },
        {
          'text':
              'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
          'count': 3,
        },
        {
          'text':
              'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
          'count': 1,
        },
        {
          'text':
              'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
          'count': 3,
        },
        {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'count': 100},
        {'text': 'أستغفر الله وأتوب إليه', 'count': 100},
      ],
    },
    {
      'title': 'أذكار بعد الصلاة',
      'icon': Icons.mosque_rounded,
      'color': const Color(0xFF81C784),
      'content': [
        {'text': 'أستغفر الله (ثلاثاً)', 'count': 3},
        {
          'text':
              'اللَّهُمَّ أَنْتَ السَّلامُ، ومِنْكَ السَّلامُ، تَبَارَكْتَ يَا ذَا الجَلالِ والإِكْرَامِ',
          'count': 1,
        },
        {
          'text':
              'لا إِلَهَ إِلاَّ اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ لا مَانِعَ لِمَا أَعْطَيْتَ، وَلا مُعْطِيَ لِمَا مَنَعْتَ، وَلا يَنْفَعُ ذَا الجَدِّ مِنْكَ الجَدُّ',
          'count': 1,
        },
        {
          'text':
              'سُبْحَانَ اللهِ (33) - الحَمْدُ للهِ (33) - اللهُ أَكْبَرُ (33)',
          'count': 1,
        },
        {
          'text':
              'لا إِلَهَ إِلاَّ اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ (تتمة المائة)',
          'count': 1,
        },
        {'text': 'قراءة آية الكرسي بعد كل صلاة', 'count': 1},
        {
          'text': 'قراءة المعوذات (بعد كل صلاة مرة، وبعد الفجر والمغرب 3 مرات)',
          'count': 1,
        },
      ],
    },
    {
      'title': 'أذكار النوم',
      'icon': Icons.bedtime_rounded,
      'color': const Color(0xFF7E57C2),
      'content': [
        {
          'text':
              'يجمع كفيه ثم ينفث فيهما فيقرأ (الإخلاص، الفلق، الناس) ويمسح بهما جسده (3 مرات)',
          'count': 3,
        },
        {'text': 'قراءة آية الكرسي', 'count': 1},
        {'text': 'قراءة آخر آيتين من سورة البقرة', 'count': 1},
        {
          'text':
              'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا...',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا...',
          'count': 1,
        },
        {'text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 'count': 1},
        {
          'text':
              'سُبْحَانَ اللهِ (33) - الحَمْدُ للهِ (33) - اللهُ أَكْبَرُ (34)',
          'count': 1,
        },
      ],
    },
    {
      'title': 'أذكار الاستيقاظ',
      'icon': Icons.wb_sunny_outlined,
      'color': const Color(0xFFFF7043),
      'content': [
        {
          'text':
              'الحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
          'count': 1,
        },
        {
          'text':
              'لا إِلَهَ إِلاَّ اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ...',
          'count': 1,
        },
        {
          'text':
              'الحَمْدُ للهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ',
          'count': 1,
        },
      ],
    },
    {
      'title': 'أذكار الطعام',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFEF5350),
      'content': [
        {'text': 'بِسْمِ اللَّهِ (في أوله)', 'count': 1},
        {
          'text': 'بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ (إذا نسي)',
          'count': 1,
        },
        {
          'text':
              'الحَمْدُ للهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلا قُوَّةٍ',
          'count': 1,
        },
      ],
    },
    {
      'title': 'أذكار السفر',
      'icon': Icons.flight_takeoff_rounded,
      'color': const Color(0xFF42A5F5),
      'content': [
        {
          'text':
              'سُبْحانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
          'count': 1,
        },
        {
          'text':
              'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا البِرَّ وَالتَّقْوَى، وَمِنَ العَمَلِ مَا تَرْضَى...',
          'count': 1,
        },
        {
          'text':
              'آيبُونَ، تَائِبُونَ، عَابِدُونَ، لِرَبِّنَا حَامِدُونَ (عند الرجوع)',
          'count': 1,
        },
      ],
    },
  ];

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
                    const Color(0xFFF3E5BB),
                  ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Spacer to push content below the CustomAppBar
              SizedBox(height: MediaQuery.of(context).padding.top + 5),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return FadeInRight(
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildCategoryCard(
                        _categories[index],
                        themeController,
                        responsive,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    ThemeController themeController,
    ResponsiveHelper responsive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? const Color(0xFF2C2C2C)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () {
          Get.to(() => AdhkarDetailsPage(category: category));
        },
        trailing: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: category['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(category['icon'], color: category['color'], size: 28),
        ),
        title: Text(
          category['title'],
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeController.getColor('text'),
          ),
        ),
        leading: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: themeController.getColor('textSecondary'),
          size: 18,
        ),
      ),
    );
  }
}

class AdhkarDetailsPage extends StatefulWidget {
  final Map<String, dynamic> category;
  const AdhkarDetailsPage({Key? key, required this.category}) : super(key: key);

  @override
  State<AdhkarDetailsPage> createState() => _AdhkarDetailsPageState();
}

class _AdhkarDetailsPageState extends State<AdhkarDetailsPage> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.from(
      widget.category['content'].map((e) => Map<String, dynamic>.from(e)),
    );
  }

  void _decrementCount(int index) {
    if (_items[index]['count'] > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _items[index]['count']--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.getColor('background'),
      appBar: AppBar(
        title: Text(
          widget.category['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: themeController.getColor('text'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final bool isDone = item['count'] == 0;

          return FadeInUp(
            child: GestureDetector(
              onTap: () => _decrementCount(index),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isDone ? 0.6 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDone
                        ? themeController.getColor('primary').withOpacity(0.05)
                        : (themeController.isDarkMode.value
                              ? const Color(0xFF2C2C2C)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDone
                          ? Colors.green.withOpacity(0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        item['text'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          fontFamily: 'Amiri',
                          color: themeController.getColor('text'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDone
                              ? Colors.green
                              : const Color(0xFFAC844D),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          isDone ? 'تم' : '${item['count']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
