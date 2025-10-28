import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'widgets/training_intro_card.dart';
import 'widgets/training_card_news_viewer.dart';
import 'widgets/training_completion_card.dart';
import 'package:sync2sing/config/theme/app_colors.dart';


class TrainingCardPage extends StatefulWidget {
  final String trainingType; // 'PITCH', 'RHYTHM', 'PRONUNCIATION'
  final String difficulty; // 'HIGH', 'MEDIUM', 'LOW'
  final String title;
  final String description;
  final int sessionId;
  final int trainingId;
  final String? returnPath;

  const TrainingCardPage({
    Key? key,
    required this.trainingType,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.sessionId,
    required this.trainingId,
    this.returnPath,
  }) : super(key: key);


// 카드뉴스 이미지 하드코딩
  static const Map<String, List<String>> _imagePathsMap = {
    'pitch_high': [
      'assets/images/pitch/pitch_high_1.png',
      'assets/images/pitch/pitch_high_2.png',
      'assets/images/pitch/pitch_high_3.png',
    ],
    'pitch_medium': [
      'assets/images/pitch/pitch_middle_1.png',
      'assets/images/pitch/pitch_middle_2.png',
      'assets/images/pitch/pitch_middle_3.png',
    ],
    'pitch_low': [
      'assets/images/pitch/pitch_low_1.png',
      'assets/images/pitch/pitch_low_2.png',
    ],
    'rhythm_high': [
      'assets/images/beat/beat_high_1.png',
      'assets/images/beat/beat_high_2.png',
      'assets/images/beat/beat_high_3.png',
    ],
    'rhythm_medium': [
      'assets/images/beat/beat_middle_1.png',
      'assets/images/beat/beat_middle_2.png',
      'assets/images/beat/beat_middle_3.png',
    ],
    'rhythm_low': [
      'assets/images/beat/beat_low_1.png',
      'assets/images/beat/beat_low_2.png',
      'assets/images/beat/beat_low_3.png',
    ],
    'pronunciation_high': [
      'assets/images/pronunciation/pronunciation_high_1.png',
      'assets/images/pronunciation/pronunciation_high_2.png',
      'assets/images/pronunciation/pronunciation_high_3.png',
    ],
    'pronunciation_medium': [
      'assets/images/pronunciation/pronunciation_middle_1.png',
      'assets/images/pronunciation/pronunciation_middle_2.png',
    ],
    'pronunciation_low': [
      'assets/images/pronunciation/pronunciation_low_1.png',
      'assets/images/pronunciation/pronunciation_low_2.png',
      'assets/images/pronunciation/pronunciation_low_3.png',
    ],

  };


  @override
  State<TrainingCardPage> createState() => _TrainingCardPageState();
}

class _TrainingCardPageState extends State<TrainingCardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 하드코딩된 데이터
  late List<String> _cardNewsImages;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  void _loadTrainingData() {
    // 하드코딩: 나중에 API로 교체할 부분
    _cardNewsImages = _getCardNewsImages(widget.trainingType, widget.difficulty);
    _totalPages = 2 + _cardNewsImages.length;
  }

  List<String> _getCardNewsImages(String type, String difficulty) {

    final key = '${type.toLowerCase()}_${difficulty.toLowerCase()}';

    final images = TrainingCardPage._imagePathsMap[key] ?? [];

    if (images.isEmpty) {
      TrainingCardPage._imagePathsMap.keys.forEach((k) {
      });
    } else {
      images.forEach((img) {
      });
    }

    return images;
  }

  bool _isPageScrollable(int pageIndex) {
    // 소개 페이지와 완료 페이지는 스크롤 불가
    if (pageIndex == 0) return false;  // 소개 페이지
    if (pageIndex == _totalPages - 1) return false;  // 완료 페이지
    return true;
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale8,
      body: PageView.builder(
        controller: _pageController,
        physics: _isPageScrollable(_currentPage)
            ? const PageScrollPhysics()  // 카드뉴스: 스크롤 가능
            : const NeverScrollableScrollPhysics(),  // 소개/완료: 스크롤 불가
        itemCount: _totalPages,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          debugPrint(' 빌드 중인 페이지 인덱스: $index');
          if (index == 0) {
            // 첫 페이지: 소개
            debugPrint(' → 소개 페이지');
            return TrainingIntroCard(
              iconPath: 'assets/images/sync2sing_logo_v1.png',
              title: widget.title,
              subtitle: widget.description,
              onStart: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            );
          } else if (index <= _cardNewsImages.length) {
            // 중간 페이지: 카드뉴스
            debugPrint(' → 카드뉴스 페이지 (${index - 1}/${_cardNewsImages.length})');
            return TrainingCardNewsViewer(
              imagePaths: _cardNewsImages,
              currentIndex: index - 1,
            );
          } else {
            // 마지막 페이지: 완료
            debugPrint('→ 완료 페이지');
            return TrainingCompletionCard(
              iconPath: 'assets/images/training_complete_icon.png',
              title: '훈련참여완료',
              subtitle: widget.description,
              sessionId: widget.sessionId,
              trainingId: widget.trainingId,
              onConfirm: () async{
                await Future.delayed(const Duration(milliseconds: 100));


                if (!context.mounted) return;

                // returnPath가 있으면 사용, 없으면 메인으로
                if (widget.returnPath != null) {
                  context.go(widget.returnPath!);
                } else {
                  context.go(AppRoutePaths.mainHome);  // Navigator.pop 대신!
                }
              }
            );
          }
        },
      ),
    );
  }
}
