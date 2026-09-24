import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';

class ChangeCommuneUseCase {
  const ChangeCommuneUseCase(this._repository);

  final AuthRepository _repository;

  Future<CitizenSession> call(String communeSlug) =>
      _repository.changeCommune(communeSlug);
}
