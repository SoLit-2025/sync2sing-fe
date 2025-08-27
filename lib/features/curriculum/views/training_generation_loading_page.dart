import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync2sing/config/routes/route_names.dart';
import 'package:sync2sing/features/curriculum/logics/curriculum_generation_request.dart';
import 'package:sync2sing/features/shared/logics/dio_factory.dart';
import 'package:sync2sing/features/shared/logics/secure_storage.dart';
import 'package:sync2sing/features/shared/logics/training_mode.dart';
import 'package:sync2sing/features/shared/views/custom_loading_page.dart';

class TrainingGenerationLoadingPage extends StatefulWidget {
  final CurriculumGenerationRequest curriculumGenerationRequest;
  const TrainingGenerationLoadingPage({super.key, required this.curriculumGenerationRequest});

  @override
  State<TrainingGenerationLoadingPage> createState() => _TrainingGenerationLoadingPageState();
}

class _TrainingGenerationLoadingPageState extends State<TrainingGenerationLoadingPage> {
  late Future<Map<String, dynamic>> response;
  Future<Map<String, dynamic>> _fetchPost() async {
    final dioFactory = DioFactory(SecureStorage());
    final response = await dioFactory.post(
      '/training/curriculum',
      data: jsonEncode(widget.curriculumGenerationRequest.toUpperJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('API 요청 실패');
    }
  }

  @override
  void initState() {
    response = _fetchPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: response,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) {
          return Scaffold(body: CustomLoading(text: "맞춤형 훈련 생성 중입니다..."));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("오류가 발생했습니다.")));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 화면이 빌드될 때까지 기다린 후 페이지 이동
            final path =
                widget.curriculumGenerationRequest.trainingMode == TrainingMode.solo
                    ? AppRoutePaths.soloTrainingHome
                    : AppRoutePaths.duetTrainingHome;
            context.go(path);
          });
          return SizedBox.shrink();
        }
      },
    );
  }
}
