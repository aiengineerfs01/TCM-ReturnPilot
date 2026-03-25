import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/presentation/interview/cubit/interview_welcome_cubit.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/interview_welcome_screen.dart';
import 'package:tcm_return_pilot/presentation/interview/widgets/before_we_begin_screen.dart';
import 'package:tcm_return_pilot/presentation/interview/interview_chat_screen.dart';

/// Interview tab content for the main navigation screen.
/// Manages the interview onboarding flow:
/// 1. Welcome screen (Welcome to ReturnPilot)
/// 2. Before We Begin screen
/// 3. Interview chat screen
class InterviewTab extends StatefulWidget {
  const InterviewTab({super.key});

  @override
  State<InterviewTab> createState() => _InterviewTabState();
}

class _InterviewTabState extends State<InterviewTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InterviewWelcomeCubit, InterviewWelcomeState>(
      builder: (context, state) {
        switch (state.currentStep) {
          case InterviewWelcomeCubit.welcomeStep:
            return InterviewWelcomeScreen(
              onStartTaxReturn: context.read<InterviewWelcomeCubit>().onStartTaxReturn,
            );

          case InterviewWelcomeCubit.beforeWeBeginStep:
            return BeforeWeBeginScreen(
              onUploadDocuments: context.read<InterviewWelcomeCubit>().onUploadDocuments,
              onStartInterview: context.read<InterviewWelcomeCubit>().onStartInterview,
            );

          case InterviewWelcomeCubit.interviewStep:
          default:
            return const InterviewChatScreen();
        }
      },
    );
  }
}
