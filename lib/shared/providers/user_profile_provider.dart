import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileState {
  final String? gender;
  final int? birthYear;

  UserProfileState({this.gender, this.birthYear});
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(UserProfileState());

  void setGender(String gender) {
    state = UserProfileState(gender: gender, birthYear: state.birthYear);
  }

  void setBirthYear(int year) {
    state = UserProfileState(gender: state.gender, birthYear: year);
  }

  void clear() => state = UserProfileState();
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>(
      (ref) => UserProfileNotifier(),
    );
