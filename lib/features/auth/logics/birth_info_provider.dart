import 'package:flutter_riverpod/flutter_riverpod.dart';

class BirthInfo {
  final String? gender;
  final String? birthYear;
  const BirthInfo({this.gender, this.birthYear});

  BirthInfo copyWith({String? gender, String? birthYear}) {
    return BirthInfo(
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
    );
  }
}

final birthInfoProvider = StateProvider<BirthInfo>((ref) => const BirthInfo());
