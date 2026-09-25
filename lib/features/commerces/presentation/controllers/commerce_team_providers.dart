import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/commerces/data/datasources/commerce_team_api_datasource.dart';
import 'package:civic_app/features/commerces/data/repositories/commerce_team_repository_impl.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';
import 'package:civic_app/features/commerces/domain/usecases/add_team_member_usecase.dart';
import 'package:civic_app/features/commerces/domain/usecases/cancel_team_invitation_usecase.dart';
import 'package:civic_app/features/commerces/domain/usecases/get_commerce_team_usecase.dart';
import 'package:civic_app/features/commerces/domain/usecases/remove_team_member_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commerceTeamRepositoryProvider = Provider<CommerceTeamRepository>(
  (ref) => CommerceTeamRepositoryImpl(
    CommerceTeamApiDatasource(ref.watch(apiClientProvider)),
  ),
);

final getCommerceTeamUseCaseProvider = Provider<GetCommerceTeamUseCase>(
  (ref) => GetCommerceTeamUseCase(ref.watch(commerceTeamRepositoryProvider)),
);

final addTeamMemberUseCaseProvider = Provider<AddTeamMemberUseCase>(
  (ref) => AddTeamMemberUseCase(ref.watch(commerceTeamRepositoryProvider)),
);

final removeTeamMemberUseCaseProvider = Provider<RemoveTeamMemberUseCase>(
  (ref) => RemoveTeamMemberUseCase(ref.watch(commerceTeamRepositoryProvider)),
);

final cancelTeamInvitationUseCaseProvider =
    Provider<CancelTeamInvitationUseCase>(
      (ref) => CancelTeamInvitationUseCase(
        ref.watch(commerceTeamRepositoryProvider),
      ),
    );

final commerceTeamProvider = FutureProvider.autoDispose
    .family<CommerceTeam, String>(
      (ref, commerceId) =>
          ref.watch(getCommerceTeamUseCaseProvider)(commerceId),
    );
