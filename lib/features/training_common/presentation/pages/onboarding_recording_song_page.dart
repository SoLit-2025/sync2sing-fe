import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';
import 'package:sync2sing/features/training_common/presentation/widgets/music_content_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/shared/providers/audio_recorder_provider.dart';
import 'package:sync2sing/shared/providers/vocal_analysis_submit_provider.dart';
import 'package:sync2sing/shared/providers/vocal_result_provider.dart';
import 'package:sync2sing/shared/widgets/page_indicator.dart';

/// 온보딩 과정의 녹음 페이지
///
/// 이 페이지의 역할:
/// 1. 사용자에게 도레미송을 들려주고 따라 부르도록 안내
/// 2. MusicContentPlayer를 통해 음정/박자 시각화 제공
/// 3. 녹음 완료 후 보컬 분석 리포트 생성으로 이동
///
/// 페이지 구성:
/// - 상단: 페이지 인디케이터 (현재 5/6 단계)
/// - 중간: 음악 플레이어 및 시각화 영역
/// - 하단: 보컬 분석 리포트 생성 버튼
class OnboardingRecordingSongPage extends StatelessWidget {
  const OnboardingRecordingSongPage({super.key});

  /// 보컬 분석 버튼 활성화 조건을 확인하는 함수
  ///
  /// 현재는 항상 true를 반환하지만, 추후 다음 조건들을 추가할 수 있습니다:
  /// - 최소 녹음 시간 달성 여부
  /// - 음정 정확도 기준 달성 여부
  /// - 필수 구간 녹음 완료 여부
  bool isVocalAnalysisButtonEnabled() {
    // 보컬 분석 버튼 활성화 조건
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 키보드가 올라와도 화면 크기가 변하지 않도록 설정
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity, // 수평 중앙 정렬
          padding: EdgeInsets.fromLTRB(0, 12.h, 0, 40.h), // 상하 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 상단 페이지 인디케이터
              /// 현재 진행 상황을 사용자에게 시각적으로 표시
              /// 5/6 단계: 거의 마지막 단계임을 알려줍니다
              const PageIndicator(currentPage: 5, pageCount: 6),

              /// 위와 중간 사이 간격
              /// Spacer는 남은 공간을 균등하게 분배합니다
              Spacer(),

              /// 중간 콘텐츠 영역
              /// 음악 플레이어와 시각화가 들어가는 메인 영역
              Container(
                width: 327.w,
                padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 20.h),
                constraints: BoxConstraints(minHeight: 300.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: const Color(0xFFECECEC), // 연한 회색 배경
                ),

                /// MusicContentPlayer: 음악 재생, 녹음, 시각화를 담당하는 핵심 위젯
                /// 이 위젯에서 모든 음악 관련 기능이 처리됩니다
                child: MusicContentPlayer(),
              ),

              /// 중간과 버튼 사이 간격
              Spacer(),

              /// 하단 버튼
              /// 보컬 분석 리포트 생성 버튼
              SizedBox(
                width: 327.w,
                height: 50.w,
                child: Consumer(
                  builder: (context, ref, child) {
                    return CupertinoButton(
                      /// 버튼 색상 설정
                      /// 활성화 시: 분홍색, 비활성화 시: 연한 분홍색
                      color: AppColors.primaryPink,
                      disabledColor: AppColors.primaryPinkDisabled,
                      borderRadius: BorderRadius.circular(10.w),

                      /// 버튼 클릭 시 동작
                      /// 활성화 조건을 만족하면 분석 로딩 페이지로 이동
                      onPressed:
                          isVocalAnalysisButtonEnabled()
                              ? () async {
                                /// vocalAnalysisSubmitProvider 새로고침
                                /// 이전 분석 결과를 초기화하고 새로운 분석 시작
                                ref.refresh(vocalAnalysisSubmitProvider);

                                /// 파일 경로 및 정확도 저장
                                /// *** ref 를 dispose() 에서 사용할 수 없어서 여기서 저장하게 로직을 작성하였습니다. -> 나중에 리팩토링될 수 있음.
                                ref
                                    .read(vocalResultProvider.notifier)
                                    .setWavFilePath(
                                      ref.read(audioRecorderProvider.notifier).getWavFilePath(),
                                    ); // 음성 파일 경로
                                ref
                                    .read(vocalResultProvider.notifier)
                                    .setPitchAccuracy(50); // 음정 정확도 저장
                                ref
                                    .read(vocalResultProvider.notifier)
                                    .setRhythmAccuracy(60); // 박자 정확도 저장

                                /// *** 저장한 것: 파일 경로 및 정확도 조회하기
                                final vocalPitchData = ref.watch(vocalResultProvider);
                                debugPrint(
                                  "파일 경로 및 정확도 저장: ${vocalPitchData.wavFilePath} | ${vocalPitchData.pitchAccuracy} | ${vocalPitchData.rhythmAccuracy}",
                                );

                                ref.invalidate(audioRecorderProvider);

                                /// 분석 로딩 페이지로 이동
                                /// 여기서 실제 AI 보컬 분석이 수행됩니다
                                context.goNamed(AppRouteNames.analysisLoading);
                              }
                              : null, // 비활성화 시 null (클릭 불가)
                      /// 버튼 텍스트
                      /// 활성화 상태에 따라 텍스트 스타일이 달라집니다
                      child: Text(
                        "보컬 분석 리포트 생성하기",
                        style:
                            isVocalAnalysisButtonEnabled()
                                ? AppTextStyles
                                    .body1BoldWhite // 활성화: 굵은 흰색
                                : AppTextStyles.body1White, // 비활성화: 일반 흰색
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
}
