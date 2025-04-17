import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/audio_environment_check_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_question_page.dart';
import '../../features/onboarding/presentation/pages/user_birth_info_input_page.dart';
import '../../features/onboarding/voice_analysis/presentation/pages/voice_sample_page.dart';
import '../../features/onboarding/voice_analysis/presentation/pages/maximum_pitch_page.dart';
import '../../features/onboarding/voice_analysis/presentation/pages/minimum_pitch_page.dart';
import '../../features/training_common/presentation/pages/onboarding_recording_guide_page.dart';
import '../../features/training_common/presentation/pages/onboarding_recording_song_page.dart';
import '../../features/training_common/presentation/pages/vocal_analysis_loading_page.dart';
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
    path: AppRoutePaths.userBirthInfo ,
    name: AppRouteNames.userBirthInfo ,
    builder: (context, state) => const UserBirthInfoInputPage(),
  ),
  GoRoute(
    path: AppRoutePaths.voiceSample,
    name: AppRouteNames.voiceSample,
    builder: (context, state) => const VoiceSamplePage(),
  ),
  GoRoute(
    path: AppRoutePaths.minimumPitch ,
    name: AppRouteNames.minimumPitch ,
    builder: (context, state) => const MinimumPitchPage(),
  ),
  GoRoute(
    path: AppRoutePaths.maximumPitch ,
    name: AppRouteNames.maximumPitch ,
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
    builder: (context, state) => const VocalAnalysisLoadingPage(),
  ),
];
