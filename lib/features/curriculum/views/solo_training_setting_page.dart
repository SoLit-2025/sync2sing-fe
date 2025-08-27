import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import '../logics/selected_song_provider.dart';

class SoloTrainingSettingPage extends ConsumerStatefulWidget {
  const SoloTrainingSettingPage({super.key});

  @override
  ConsumerState<SoloTrainingSettingPage> createState() => _SoloTrainingSettingPageState();
}

class _SoloTrainingSettingPageState extends ConsumerState<SoloTrainingSettingPage> {
  int? _selectedDays;
  final List<int> _options = [3, 7, 14];

  @override
  Widget build(BuildContext context) {
    // 선택된 노래 정보 감지
    final selectedSong = ref.watch(selectedSongProvider);

    // 선택된 노래가 유효한지 확인
    final bool isSongSelected = (selectedSong.id != null &&
        selectedSong.title != null &&
        selectedSong.artist != null &&
        selectedSong.albumArtUrl != null &&
        selectedSong.voiceType != null
    );

    // 연습곡과 훈련기간이 모두 선택되었는지 확인
    final bool isFormValid = isSongSelected && _selectedDays != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    _buildSongSection(selectedSong, isSongSelected),
                    SizedBox(height: 40.h),
                    _buildTrainingDaySection(),
                  ],
                ),
              ),
              _buildConfirmButton(isFormValid),
              SizedBox(height: 150.h),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 네비게이션 영역 = 뒤로가기 버튼 + 페이지 제목
  Widget _buildAppBar() {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutePaths.soloTrainingHome),
            child: Image.asset(
              'assets/images/left_arrow_icon.png',
              width: 14.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Text(
              "솔로 트레이닝 설정",
              style: AppTextStyles.heading4Bold.copyWith(color: AppColors.grayscale1),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }

  // 연습곡 선택 영역 = '연습곡 선택' 소제목 + 연습곡 정보 카드
  Widget _buildSongSection(selectedSong, bool isSongSelected) {
    return SizedBox(
      width: 327.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "연습곡 선택",
            style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale2),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push("${AppRoutePaths.songList}/solo");
            },
            child: _buildSongCard(selectedSong, isSongSelected),
          ),
        ],
      ),
    );
  }

  // 노래 정보 카드 = 앨범아트 + 노래 정보
  Widget _buildSongCard(selectedSong, bool isSongSelected) {
    return SizedBox(
      width: 327.w,
      height: 80.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAlbumArt(isSongSelected, selectedSong.albumArtUrl),
          SizedBox(width: 15.w),
          Expanded(
            child: _buildSongInfoColumn(isSongSelected, selectedSong),
          ),
        ],
      ),
    );
  }

  // 앨범아트
  Widget _buildAlbumArt(bool isSelected, String? url) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: AppColors.primaryPinkDisabled,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: isSelected && url != null && url.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(5.r),
        child: Image.network(
          url,
          width: 80.w,
          height: 80.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAlbumArt(),
        ),
      )
          : _buildDefaultAlbumArt(),
    );
  }

  // 기본 앨범아트
  Widget _buildDefaultAlbumArt() {
    return Center(
      child: Image.asset(
        'assets/images/default_album_art.png',
        width: 35.w,
        height: 35.h,
        fit: BoxFit.contain,
      ),
    );
  }

  // 노래 정보 = 노래 제목 + 가수 이름 + 성부 칩
  Widget _buildSongInfoColumn(bool isSelected, selectedSong) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSongInfo(isSelected, selectedSong),
        SizedBox(height: 6.h),
        _buildVoiceTypeChip(isSelected, selectedSong),
      ],
    );
  }

  // 노래 제목 & 가수 이름 로직
  Widget _buildSongInfo(bool isSelected, selectedSong) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSelected ? (selectedSong.title ?? '') : "연습할 노래를 선택해주세요",
          style: AppTextStyles.body1Bold.copyWith(
            color: isSelected ? AppColors.grayscale1 : AppColors.grayscale3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          isSelected ? (selectedSong.artist ?? '') : "선택한 노래가 이곳에 표시됩니다",
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? AppColors.grayscale3 : AppColors.grayscale5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 성부 칩 로직
  Widget _buildVoiceTypeChip(bool isSelected, selectedSong) {
    if (isSelected && selectedSong.voiceType != null && selectedSong.voiceType != '') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.grayscale3,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          selectedSong.voiceType!,
          style: AppTextStyles.body6.copyWith(color: AppColors.grayscale8),
        ),
      );
    } else {
      return SizedBox(
        width: 60.w,
        height: 20.h,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.grayscale6,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  // 훈련기간 선택 영역 = '훈련기간 선택' 소제목 + 훈련기간 선택 버튼
  Widget _buildTrainingDaySection() {
    return SizedBox(
      width: 327.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "훈련기간 선택",
            style: AppTextStyles.body1Bold.copyWith(color: AppColors.grayscale2),
          ),
          SizedBox(height: 16.h),
          _buildTrainingDayButtons(),
        ],
      ),
    );
  }

  // 훈련기간 선택 버튼
  Widget _buildTrainingDayButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildDayBtn(3, isFirst: true),
        ),
        Expanded(
          child: _buildDayBtn(7),
        ),
        Expanded(
          child: _buildDayBtn(14, isLast: true),
        ),
      ],
    );
  }

  // 훈련기간 선택 버튼 로직
  Widget _buildDayBtn(int days, {bool isFirst = false, bool isLast = false}) {
    final bool isSelected = _selectedDays == days;

    EdgeInsets margin;
    if (isFirst) {
      margin = EdgeInsets.only(right: 6.w);
    } else if (isLast) {
      margin = EdgeInsets.only(left: 6.w);
    } else {
      margin = EdgeInsets.symmetric(horizontal: 6.w);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
      },
      child: Container(
        margin: margin,
        height: 50.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : AppColors.grayscale6,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "$days일",
          style: AppTextStyles.body1.copyWith(
            color: isSelected ? AppColors.grayscale8 : AppColors.grayscale3,
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 확인 버튼 로직
  Widget _buildConfirmButton(bool isFormValid) {
    return SizedBox(
      width: 327.w,
      height: 50.h,
      child: ElevatedButton(
        onPressed:
        isFormValid
            ? () async {
          ref.read(selectedSongProvider.notifier).setTrainingDays(_selectedDays!);
          final data = {
            "song_id": 2 ,// ref.read(selectedSongProvider).id,
            "key_adjustment": 0,
            "training_days": ref.read(selectedSongProvider).trainingDays,
          };
          final response  = await DioFactory(
            SecureStorage(),
          ).post('/solo-training/session', data: jsonEncode(data));

          debugPrint("커리큘럼 생성 확인: ${response.data}");

          if (response.statusCode != 201) {

            _showError("설정 실패! 다시 확인해주세요.");
          }
          // debugPrint
          context.go(
            "${AppRoutePaths.songExampleVideo}/solo/pre/${ref.watch(selectedSongProvider).id}",
          );
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? AppColors.primaryPink : AppColors.primaryPinkDisabled,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text("확인", style: AppTextStyles.body1White),
      ),
    );
  }

}