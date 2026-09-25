import 'package:equatable/equatable.dart';

sealed class SignUpOutcome extends Equatable {
  const SignUpOutcome();
}

class SignUpCompleted extends SignUpOutcome {
  const SignUpCompleted();

  @override
  List<Object?> get props => [];
}

class SignUpNeedsVerification extends SignUpOutcome {
  const SignUpNeedsVerification({
    required this.email,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final String email;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;

  @override
  List<Object?> get props => [email, expiresAt, resendAvailableAt];
}
