import 'package:go_router/go_router.dart';
import 'package:sync2sing/features/report/views/vocal_analysis_loading_handler.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/minimum_pitch_page.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/onboarding_recording_song_page.dart';
import 'package:sync2sing/features/vocal_analysis/views/pages/voice_sample_page.dart';
import '../../features/onboarding/views/audio_environment_check_page.dart';
import '../../features/onboarding/views/onboarding_question_page.dart';
import '../../features/onboarding/views/user_birth_info_input_page.dart';
import '../../features/vocal_analysis/views/pages/maximum_pitch_page.dart';
import '../../features/onboarding/views/onboarding_recording_guide_page.dart';
import 'route_names.dart';

final List<GoRoute> onboardingRoutes = [
  GoRoute(
    path: AppRoutePaths.onboardingQuestion,
    name: AppRouteNames.onboardingQuestion,
    builder: (context, state) => const OnboardingQuestionPage(),
  ),
  GoRoute(
    path: AppRoutePaths.audioEnvironment,
    name: AppRouteNames.audioEnvironment,
    builder: (context, state) => const AudioEnvironmentCheckPage(),
  ),
  GoRoute(
    path: AppRoutePaths.userBirthInfoInput,
    name: AppRouteNames.userBirthInfoInput,
    builder: (context, state) => const UserBirthInfoInputPage(),
  ),
  GoRoute(
    path: AppRoutePaths.voiceSample,
    name: AppRouteNames.voiceSample,
    builder: (context, state) => const VoiceSamplePage(),
  ),
  GoRoute(
    path: AppRoutePaths.minimumPitch,
    name: AppRouteNames.minimumPitch,
    builder: (context, state) => const MinimumPitchPage(),
  ),
  GoRoute(
    path: AppRoutePaths.maximumPitch,
    name: AppRouteNames.maximumPitch,
    builder: (context, state) => const MaximumPitchPage(),
  ),
  GoRoute(
    path: AppRoutePaths.onboardingRecordingGuide,
    name: AppRouteNames.onboardingRecordingGuide,
    builder: (context, state) => const OnboardingRecordingGuidePage(),
  ),
  GoRoute(
    path: AppRoutePaths.onboardingRecordingSong,
    name: AppRouteNames.onboardingRecordingSong,
    builder: (context, state) => const OnboardingRecordingSongPage(),
  ),
  GoRoute(
    path: AppRoutePaths.vocalAnalysisLoading,
    name: AppRouteNames.analysisLoading,
    builder: (context, state) => const VocalAnalysisLoadingHandler(),
  ),
];
