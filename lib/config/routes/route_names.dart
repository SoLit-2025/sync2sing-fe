abstract class AppRouteNames {
  // onboarding
  static const onboardingQuestion = 'onboardingQuestion';
  static const audioEnvironment = 'audioEnvironment';
  static const userBirthInfoInput = 'userBirthInfo';
  static const voiceSample = 'voiceSample';
  static const minimumPitch = 'minimumPitch';
  static const maximumPitch = 'maximumPitch';
  static const onboardingRecordingGuide = 'onboardingRecordingGuide';
  static const onboardingRecordingSong = 'onboardingRecordingSong';
  static const analysisLoading = 'analysisLoading';

  // auth
  static const signupIdPassword = 'signupIdPassword';
  static const signupProfileInfo = 'signupProfileInfo';
  static const signupComplete = 'signupComplete';
  static const login = 'login';

  // 로그인 후 진입
  static const mainHome = 'main';
  static const soloTrainingHome = 'soloTraining';
  static const duetTrainingHome = 'duetTrainingHome';
  static const my = 'my';
  static const vocalAnalysisReport = 'vocalAnalysisReport';
}

abstract class AppRoutePaths {
  static const onboardingQuestion = '/onboarding';
  static const audioEnvironment = '/onboarding/audio_env';
  static const userBirthInfoInput = '/onboarding/birth_info';
  static const voiceSample = '/onboarding/voice_sample';
  static const minimumPitch = '/onboarding/min_pitch';
  static const maximumPitch = '/onboarding/max_pitch';
  static const onboardingRecordingGuide = '/onboarding/recording_guide';
  static const onboardingRecordingSong = '/onboarding/recording_song';
  static const vocalAnalysisLoading = '/onboarding/analysis_loading';

  // auth
  static const signupIdPassword = '/auth/signup_id_password';
  static const signupProfileInfo = '/auth/signup_profile_info';
  static const signupComplete = '/auth/signup_complete';
  static const login = '/auth/login';

  // 로그인 후 진입
  static const mainHome = '/main';
  static const soloTrainingHome = '/solo_training/home';
  static const duetTrainingHome = '/duet_training/home';
  static const my = '/my';
  static const vocalAnalysisReport = '/vocal_analysis_report';
}
