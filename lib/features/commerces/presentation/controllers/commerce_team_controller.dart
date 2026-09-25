import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/domain/usecases/add_team_member_usecase.dart';
import 'package:civic_app/features/commerces/domain/usecases/cancel_team_invitation_usecase.dart';
import 'package:civic_app/features/commerces/domain/usecases/remove_team_member_usecase.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerce_team_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommerceTeamController extends StateNotifier<AsyncValue<void>> {
  CommerceTeamController(
    this._ref,
    this._commerceId,
    this._add,
    this._remove,
    this._cancel,
  ) : super(const AsyncData(null));

  final Ref _ref;
  final String _commerceId;
  final AddTeamMemberUseCase _add;
  final RemoveTeamMemberUseCase _remove;
  final CancelTeamInvitationUseCase _cancel;

  Future<TeamAddOutcome?> add(String email) async {
    TeamAddOutcome? outcome;
    final succeeded = await _run(() async {
      outcome = await _add(_commerceId, email);
    });
    return succeeded ? outcome : null;
  }

  Future<bool> remove(String memberId) =>
      _run(() => _remove(_commerceId, memberId));

  Future<bool> cancelInvitation(String invitationId) =>
      _run(() => _cancel(_commerceId, invitationId));

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      _ref.invalidate(commerceTeamProvider(_commerceId));
    });
    return !state.hasError;
  }
}

final commerceTeamControllerProvider = StateNotifierProvider.autoDispose
    .family<CommerceTeamController, AsyncValue<void>, String>(
      (ref, commerceId) => CommerceTeamController(
        ref,
        commerceId,
        ref.watch(addTeamMemberUseCaseProvider),
        ref.watch(removeTeamMemberUseCaseProvider),
        ref.watch(cancelTeamInvitationUseCaseProvider),
      ),
    );
